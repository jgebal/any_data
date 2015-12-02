CREATE OR REPLACE PACKAGE anydata_reporter IS

  NEW_LINE         CONSTANT VARCHAR2(2) := CHR(10);
  INDENT_AMOUNT    CONSTANT PLS_INTEGER := 2;

  FUNCTION get_report( p_field_name VARCHAR2, p_field_value ANYDATA, p_indent INTEGER := 0 ) RETURN VARCHAR2;

  FUNCTION get_report( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  FUNCTION report_complex_type( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  FUNCTION report_object_type( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  FUNCTION report_collection_type( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

END;
/
