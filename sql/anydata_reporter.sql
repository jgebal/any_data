DROP PACKAGE anydata_reporter;
/

CREATE OR REPLACE PACKAGE anydata_reporter IS

  FUNCTION get_report( p_field_name VARCHAR2, p_field_value ANYDATA ) RETURN VARCHAR2;

END;
/

CREATE OR REPLACE PACKAGE BODY anydata_reporter IS

  NEW_LINE         CONSTANT VARCHAR2(2) := CHR(10);
  INDENT_AMOUNT    CONSTANT PLS_INTEGER := 2;


  FUNCTION get_report( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;

  FUNCTION report_object( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2;


  FUNCTION report_object( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
    v_field          BETTER_ANYDATA := p_field;
    v_attr_type_info ANYTYPE_INFO;
    v_result         VARCHAR2(32767);
    v_elem_idx       INTEGER := 1;
    BEGIN
      v_field.base_data.piecewise();
      LOOP
        EXIT WHEN v_elem_idx > COALESCE( p_type_info.COUNT, v_elem_idx );
        BEGIN
          v_attr_type_info := ANYTYPE_INFO( v_elem_idx, p_type_info.attribute_type );
          v_result := v_result || NEW_LINE
                      || get_report( v_field, v_attr_type_info, p_indent ) || ',';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
        END;
        v_elem_idx := v_elem_idx + 1;
      END LOOP;
      v_result := RTRIM(v_result,',') || NEW_LINE;
      RETURN v_result;
    END;

  FUNCTION get_report( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent INTEGER ) RETURN VARCHAR2 IS
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
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_OBJECT   THEN '{'||report_object( p_field, p_type_info, p_indent + INDENT_AMOUNT )||'}'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_VARRAY   THEN '['||report_object( p_field, p_type_info, p_indent + INDENT_AMOUNT )||']'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_TABLE    THEN '['||report_object( p_field, p_type_info, p_indent + INDENT_AMOUNT )||']'
          WHEN p_type_info.type_code = DBMS_TYPES.TYPECODE_NAMEDCOLLECTION THEN '['||report_object( p_field, p_type_info, p_indent + INDENT_AMOUNT )||']'
        END;
    END;

  FUNCTION get_report( p_field_name VARCHAR2, p_field_value ANYDATA ) RETURN VARCHAR2 IS
    v_type_info  ANYTYPE_INFO := ANYTYPE_INFO( p_field_name, p_field_value );
    v_field      BETTER_ANYDATA := BETTER_ANYDATA( p_field_value );
    BEGIN
      DBMS_OUTPUT.enable(null);
      DBMS_OUTPUT.PUT_LINE('v_type_info.type_name: '||v_type_info.type_name);
      RETURN get_report( v_field, v_type_info, 0 );
    END;

END;
/
