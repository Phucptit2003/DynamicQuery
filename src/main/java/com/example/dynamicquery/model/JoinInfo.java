package com.example.dynamicquery.model;

public class JoinInfo {
    private String joinTable;
    private String baseColumn;
    private String joinColumn;

    // Getters and Setters
    public String getJoinTable() { return joinTable; }
    public void setJoinTable(String joinTable) { this.joinTable = joinTable; }
    public String getBaseColumn() { return baseColumn; }
    public void setBaseColumn(String baseColumn) { this.baseColumn = baseColumn; }
    public String getJoinColumn() { return joinColumn; }
    public void setJoinColumn(String joinColumn) { this.joinColumn = joinColumn; }
}
