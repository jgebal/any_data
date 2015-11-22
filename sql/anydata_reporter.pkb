CREATE OR REPLACE PACKAGE BODY anydata_reporter IS

  NEW_LINE         CONSTANT VARCHAR2(2) := CHR(10);
  INDENT_AMOUNT    CONSTANT PLS_INTEGER := 2;


  --declaration

  FUNCTION get_report( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  --definition

  FUNCTION report_complex_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
    v_attr_type_info ANYTYPE_INFO;
    v_report         VARCHAR2(32767);
    v_result         VARCHAR2(32767);
    v_elem_idx       INTEGER := 1;
    BEGIN
      p_field.base_data.piecewise();
      LOOP
        EXIT WHEN v_elem_idx > COALESCE( p_type_info.COUNT, v_elem_idx );
        BEGIN
          p_field.base_data.piecewise();
          v_attr_type_info := ANYTYPE_INFO( v_elem_idx, p_type_info.attribute_type );
          DBMS_OUTPUT.PUT_LINE( 'index= '||v_elem_idx||' typename=' ||v_attr_type_info.get_typename() );
          v_report := get_report( p_field, v_attr_type_info, p_indent );
          v_result := v_result || NEW_LINE || v_report || ',';
          DBMS_OUTPUT.PUT_LINE( v_report );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
        END;
        v_elem_idx := v_elem_idx + 1;
      END LOOP;
      v_result := RTRIM(v_result,',') || NEW_LINE;
      RETURN v_result;
    END;

  FUNCTION report_object_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
    v_out_anydata ANYDATA;
    v_report      VARCHAR2(32767);
    v_sql         VARCHAR2(32767);
    BEGIN
      v_sql := '
        DECLARE
          v_in_data ANYDATA := :base_data_in;
          v_obj     '||p_type_info.get_typename()||';
          v_element  BETTER_ANYDATA;
        BEGIN
          IF v_in_data.getTypeName() != '''||p_type_info.get_typename()||''' THEN
            v_in_data.piecewise();
          END IF;
          IF v_in_data.getObject( v_obj ) = DBMS_TYPES.NO_DATA THEN
            RAISE NO_DATA_FOUND;
          END IF;
          v_element := BETTER_ANYDATA( ANYDATA.convertObject( v_obj ) );
          :v_report  := anydata_reporter.report_complex_type( v_element, :p_type_info, :p_indent );
        END;';
      EXECUTE IMMEDIATE v_sql USING IN p_field.base_data, OUT v_report, IN p_type_info, IN p_indent;
      RETURN '{'||v_report||'}';
    END;

--   FUNCTION report_object_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
--     v_field BETTER_ANYDATA;
--     BEGIN
--      v_field := p_field.getObject( p_type_info );
--      RETURN '{' ||report_complex_type( v_field, p_type_info, p_indent ) ||'}';
--     END;

  FUNCTION report_collection_type( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
    v_field BETTER_ANYDATA;
    BEGIN
      v_field := p_field.getCollection( p_type_info );
      RETURN '[' ||report_complex_type( v_field, p_type_info, p_indent ) ||']';
    END;

  FUNCTION get_report( p_field IN OUT NOCOPY BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
    v_indent_str VARCHAR2(1000) := LPAD(' ',p_indent, ' ');
    BEGIN
      RETURN v_indent_str || p_type_info.get_report()
        ||CASE
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_NUMBER   THEN TO_CHAR( p_field.getNumber() )
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_VARCHAR2 THEN '"'||REPLACE( REPLACE( p_field.getVarchar2(),'\','\\'),'"','\"')||'"'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_DATE     THEN TO_CHAR( p_field.getDate(),'YYYY-MM-DD HH24:MI:SS' )
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_BDOUBLE  THEN TO_CHAR( p_field.getBDouble() )
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_BFLOAT   THEN TO_CHAR( p_field.getBFloat() )
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_BLOB     THEN '"'||TO_CHAR( utl_raw.cast_to_varchar2( dbms_lob.substr( p_field.getBlob() ) ) )||'"'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_CHAR     THEN '"'||TRIM(p_field.getChar())||'"'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_CLOB     THEN '"'||dbms_lob.substr( p_field.getClob() )||'"'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_OBJECT   THEN report_object_type( p_field, p_type_info, p_indent + INDENT_AMOUNT )
          WHEN p_type_info.type_code IN ( DBMS_TYPES.TYPECODE_VARRAY, DBMS_TYPES.TYPECODE_TABLE, DBMS_TYPES.TYPECODE_NAMEDCOLLECTION ) THEN
            report_collection_type( p_field, p_type_info, p_indent + INDENT_AMOUNT )
        END;
    END;

  FUNCTION get_report( p_field_name VARCHAR2, p_field_value ANYDATA ) RETURN VARCHAR2 IS
    v_type_info  ANYTYPE_INFO := ANYTYPE_INFO( p_field_name, p_field_value );
    v_field      BETTER_ANYDATA := BETTER_ANYDATA( p_field_value );
    BEGIN
      RETURN get_report( v_field, v_type_info, 0 );
    END;

END;
/
