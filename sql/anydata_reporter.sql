DROP TYPE anydata_reporter FORCE;
/
DROP TYPE anytype_info FORCE;
/

CREATE TYPE anytype_info AS OBJECT (
  prec        INTEGER,
  scale       INTEGER,
  len         INTEGER,
  csid        INTEGER,
  csfrm       INTEGER,
  schema_name VARCHAR2(400),
  type_name   VARCHAR2(400),
  version     VARCHAR2(400),
  count       INTEGER,
  type_code   INTEGER,
  CONSTRUCTOR FUNCTION anytype_info( pv_value ANYDATA) RETURN SELF AS RESULT,
  MEMBER FUNCTION get_report RETURN VARCHAR2
);
/

CREATE TYPE BODY anytype_info IS
  CONSTRUCTOR FUNCTION anytype_info( pv_value ANYDATA) RETURN SELF AS RESULT IS
    v_type          ANYTYPE;
    v_name_lst      DBMS_UTILITY.MAXNAME_ARRAY;
    v_dummy         INTEGER;
    function in_list( p_string in varchar2, p_separator VARCHAR2 DEFAULT '.' ) return DBMS_UTILITY.MAXNAME_ARRAY IS
      v_string        VARCHAR2(32767) := p_string||p_separator;
      v_data          DBMS_UTILITY.MAXNAME_ARRAY;
      v_start         INTEGER := 1;
      v_end           INTEGER := instr( v_string, p_separator );
      i               PLS_INTEGER := 1;
    begin
      while v_end > 0 loop
          v_data(i) := substr( v_string, v_start, v_end-v_start );
          v_start := v_end + 1;
          v_end := instr( v_string, p_separator, v_start );
          i := i + 1;
      end loop;

      return v_data;
    end;
  BEGIN
    SELF.type_code := pv_value.gettype( v_type );
    IF v_type IS NULL THEN
      v_name_lst := in_list( pv_value.GETTYPENAME() );
      SELF.schema_name := v_name_lst(1);
      SELF.type_name := v_name_lst(2);
    ELSE
      SELF.type_code := v_type.GETINFO(
        SELF.prec,
        SELF.scale,
        SELF.len,
        SELF.csid,
        SELF.csfrm,
        SELF.schema_name,
        SELF.type_name,
        SELF.version,
        SELF.count);
    END IF;
    RETURN;
  END;
  MEMBER FUNCTION get_report RETURN VARCHAR2 IS
  BEGIN
    RETURN type_name||
      CASE WHEN prec IS NOT NULL THEN
        '('||prec
        || CASE WHEN scale IS NOT NULL THEN ','||scale END
        ||')'
     END;
  END;
END;
/

CREATE TYPE anydata_reporter AS OBJECT(
  field_name  VARCHAR2(30),
  field_value ANYDATA,
  MEMBER FUNCTION get_report RETURN VARCHAR2
);
/

CREATE TYPE BODY anydata_reporter IS
  MEMBER FUNCTION get_report RETURN VARCHAR2 IS
    v_type_info anytype_info := anytype_info( field_value );
  BEGIN
    RETURN field_name||'('||v_type_info.get_report()||')=>';
  END;
END;
/
