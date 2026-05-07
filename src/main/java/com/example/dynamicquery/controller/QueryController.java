package com.example.dynamicquery.controller;

import com.example.dynamicquery.model.Condition;
import com.example.dynamicquery.model.JoinInfo;
import com.example.dynamicquery.model.QueryRequest;
import com.example.dynamicquery.model.TableSchema;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api")
public class QueryController {

    private final JdbcTemplate jdbcTemplate;

    public QueryController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/tables")
    public List<String> getTables() {
        return jdbcTemplate.queryForList("SELECT TABLE_NAME FROM USER_TABLES", String.class);
    }

    // Lấy thông tin cột của 1 bảng
    private List<Map<String, String>> getColumnsOfTable(String tableName) {
        return jdbcTemplate.query(
                "SELECT COLUMN_NAME, DATA_TYPE FROM USER_TAB_COLUMNS WHERE TABLE_NAME = ?",
                (rs, rowNum) -> {
                    Map<String, String> col = new HashMap<>();
                    col.put("name", rs.getString("COLUMN_NAME"));
                    col.put("type", rs.getString("DATA_TYPE"));
                    return col;
                },
                tableName.toUpperCase()
        );
    }

    // API lấy Bảng Gốc + Các Bảng có liên kết Khóa Ngoại
    @GetMapping("/tables/{tableName}/schema-with-joins")
    public Map<String, Object> getTableSchemaWithJoins(@PathVariable String tableName) {
        Map<String, Object> response = new HashMap<>();
        tableName = tableName.toUpperCase();

        // 1. Lấy cột của bảng gốc
        response.put("baseTable", Map.of(
                "tableName", tableName,
                "columns", getColumnsOfTable(tableName)
        ));

        // 2. Tìm các bảng có quan hệ (Oracle Foreign Key logic)
        // Query này tìm các bảng là CON (child) tham chiếu đến bảng hiện tại
        // Đã sửa "c.table_name" thành "c_parent.table_name"
        String fkQuery = "SELECT a.table_name as CHILD_TABLE, a.column_name as CHILD_COLUMN, " +
                "c_parent.table_name as PARENT_TABLE, b.column_name as PARENT_COLUMN " +
                "FROM user_cons_columns a " +
                "JOIN user_constraints c_child ON a.constraint_name = c_child.constraint_name " +
                "JOIN user_constraints c_parent ON c_child.r_constraint_name = c_parent.constraint_name " +
                "JOIN user_cons_columns b ON c_parent.constraint_name = b.constraint_name " +
                "WHERE c_child.constraint_type = 'R' " +
                "AND (c_parent.table_name = ? OR a.table_name = ?)";

        List<Map<String, Object>> relations = jdbcTemplate.queryForList(fkQuery, tableName, tableName);

        List<Map<String, Object>> joinedTables = new ArrayList<>();
        for (Map<String, Object> rel : relations) {
            String childTable = (String) rel.get("CHILD_TABLE");
            String parentTable = (String) rel.get("PARENT_TABLE");

            String relatedTable = childTable.equals(tableName) ? parentTable : childTable;
            String baseCol = childTable.equals(tableName) ? (String) rel.get("CHILD_COLUMN") : (String) rel.get("PARENT_COLUMN");
            String relatedCol = childTable.equals(tableName) ? (String) rel.get("PARENT_COLUMN") : (String) rel.get("CHILD_COLUMN");

            Map<String, Object> joinData = new HashMap<>();
            joinData.put("tableName", relatedTable);
            joinData.put("columns", getColumnsOfTable(relatedTable));
            joinData.put("baseColumn", baseCol);
            joinData.put("joinColumn", relatedCol);
            joinedTables.add(joinData);
        }

        response.put("joinedTables", joinedTables);
        return response;
    }

    @PostMapping("/execute")
    public Map<String, Object> executeQuery(@RequestBody QueryRequest request) {
        Map<String, Object> response = new HashMap<>();

        try {
            String baseTable = request.getTableName();
            StringBuilder sql = new StringBuilder("SELECT ");

            List<String> selectedCols = request.getSelectedColumns();
            List<String> groupByCols = new ArrayList<>();
            boolean hasAggregate = false;

            // =====================
            // SELECT + detect aggregate
            // =====================
            if (selectedCols == null || selectedCols.isEmpty()) {
                sql.append(baseTable).append(".*");
            } else {
                List<String> finalSelect = new ArrayList<>();

                for (String col : selectedCols) {
                    String upper = col.toUpperCase();

                    // detect hàm aggregate
                    if (upper.contains("COUNT(") ||
                            upper.contains("SUM(") ||
                            upper.contains("AVG(") ||
                            upper.contains("MIN(") ||
                            upper.contains("MAX(")) {

                        hasAggregate = true;
                        finalSelect.add(col);
                    } else {
                        finalSelect.add(col);
                        groupByCols.add(col); // chỉ add non-aggregate vào group by
                    }
                }

                sql.append(String.join(", ", finalSelect));
            }

            // =====================
            // FROM
            // =====================
            sql.append(" \nFROM ").append(baseTable);

            // =====================
            // JOIN
            // =====================
            if (request.getJoins() != null) {
                for (JoinInfo join : request.getJoins()) {
                    sql.append(" \nLEFT JOIN ").append(join.getJoinTable())
                            .append(" ON ").append(baseTable).append(".").append(join.getBaseColumn())
                            .append(" = ").append(join.getJoinTable()).append(".").append(join.getJoinColumn());
                }
            }

            // =====================
            // WHERE
            // =====================
            if (request.getConditions() != null && !request.getConditions().isEmpty()) {
                sql.append(" \nWHERE ");
                List<String> conditionStrings = new ArrayList<>();

                for (Condition cond : request.getConditions()) {
                    String val = cond.getValue().replace("'", "''");

                    // ⚠️ auto detect number
                    if (val.matches("\\d+")) {
                        conditionStrings.add(cond.getColumn() + " " + cond.getOperator() + " " + val);
                    } else {
                        conditionStrings.add(cond.getColumn() + " " + cond.getOperator() + " '" + val + "'");
                    }
                }

                sql.append(String.join(" AND ", conditionStrings));
            }

            // =====================
            // GROUP BY (auto)
            // =====================
            if (hasAggregate && !groupByCols.isEmpty()) {
                sql.append(" \nGROUP BY ").append(String.join(", ", groupByCols));
            }

            String finalSql = sql.toString();
            response.put("sql", finalSql);

            // Execute
            List<Map<String, Object>> results = jdbcTemplate.queryForList(finalSql);
            response.put("data", results);
            response.put("status", "success");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", e.getMessage());
        }

        return response;
    }
}
