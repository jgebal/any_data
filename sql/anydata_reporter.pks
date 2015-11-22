CREATE OR REPLACE PACKAGE anydata_reporter IS

  FUNCTION get_report( p_field_name VARCHAR2, p_field_value ANYDATA ) RETURN VARCHAR2;

  FUNCTION report_complex_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  FUNCTION report_object_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  FUNCTION report_collection_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

END;
/
