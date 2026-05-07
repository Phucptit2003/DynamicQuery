package com.example.dynamicquery.model;

import java.util.List;

public class TableSchema {
    private String tableName;
    private List<String> columns;

    public TableSchema(String tableName, List<String> columns) {
        this.tableName = tableName;
        this.columns = columns;
    }

    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    public List<String> getColumns() { return columns; }
    public void setColumns(List<String> columns) { this.columns = columns; }
}
