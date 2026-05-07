package com.example.dynamicquery.model;

import java.util.List;

public class QueryRequest {
    private String tableName;
    private List<String> selectedColumns;
    private List<Condition> conditions;
    private List<String> groupByColumns;
    private List<JoinInfo> joins; // THÊM MỚI

    // Thêm Getters/Setters cho joins...
    public List<JoinInfo> getJoins() { return joins; }

    // Getters and Setters
    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    public List<String> getSelectedColumns() { return selectedColumns; }
    public void setSelectedColumns(List<String> selectedColumns) { this.selectedColumns = selectedColumns; }
    public List<Condition> getConditions() { return conditions; }
    public void setConditions(List<Condition> conditions) { this.conditions = conditions; }
    public List<String> getGroupByColumns() { return groupByColumns; }
    public void setGroupByColumns(List<String> groupByColumns) { this.groupByColumns = groupByColumns; }
}
