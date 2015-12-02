DROP TYPE anytype_info FORCE;
/
CREATE TYPE anytype_info AS OBJECT (
  attribute_name VARCHAR2(400),
  attribute_type ANYTYPE,
  prec           INTEGER,
  scale          INTEGER,
  len            INTEGER,
  csid           INTEGER,
  csfrm          INTEGER,
  schema_name    VARCHAR2(400),
  type_name      VARCHAR2(400),
  version        VARCHAR2(400),
  type_code      INTEGER,
  count          INTEGER,
CONSTRUCTOR FUNCTION anytype_info( pv_attribute_name VARCHAR2, pv_value ANYDATA) RETURN SELF AS RESULT,
CONSTRUCTOR FUNCTION anytype_info( pv_child_position PLS_INTEGER, pv_parent_type ANYTYPE) RETURN SELF AS RESULT,
MEMBER FUNCTION get_child_type_info( pv_child_position PLS_INTEGER ) RETURN anytype_info,
MEMBER PROCEDURE update_from_attribute_type(SELF IN OUT NOCOPY anytype_info),
MEMBER PROCEDURE map_typecode_to_typename,
MEMBER FUNCTION get_report RETURN VARCHAR2,
MEMBER FUNCTION get_typename RETURN VARCHAR2,
MEMBER FUNCTION get_anydata_proc_suffix return VARCHAR2,
MEMBER FUNCTION anydata_converter  RETURN VARCHAR2,
MEMBER FUNCTION anydata_getter  RETURN VARCHAR2,
MEMBER FUNCTION to_string RETURN VARCHAR2
);
/

CREATE TYPE BODY anytype_info IS
  MEMBER PROCEDURE map_typecode_to_typename IS
  BEGIN
--    SELF.schema_name := 'SYS';
    SELF.type_name :=
      CASE SELF.type_code
        WHEN DBMS_TYPES.TYPECODE_DATE          THEN 'DATE'
--        WHEN 3                                 THEN 'INTEGER'
        WHEN DBMS_TYPES.TYPECODE_NUMBER        THEN 'NUMBER'
        WHEN DBMS_TYPES.TYPECODE_RAW           THEN 'RAW'
        WHEN DBMS_TYPES.TYPECODE_CHAR          THEN 'CHAR'
        WHEN DBMS_TYPES.TYPECODE_VARCHAR2      THEN 'VARCHAR2'
        WHEN DBMS_TYPES.TYPECODE_VARCHAR       THEN 'VARCHAR'
        WHEN DBMS_TYPES.TYPECODE_MLSLABEL      THEN 'MLSLABEL'
        WHEN DBMS_TYPES.TYPECODE_BLOB          THEN 'BLOB'
        WHEN DBMS_TYPES.TYPECODE_BFILE         THEN 'BFILE'
        WHEN DBMS_TYPES.TYPECODE_CLOB          THEN 'CLOB'
        WHEN DBMS_TYPES.TYPECODE_CFILE         THEN 'CFILE'
        WHEN DBMS_TYPES.TYPECODE_TIMESTAMP     THEN 'TIMESTAMP'
        WHEN DBMS_TYPES.TYPECODE_TIMESTAMP_TZ  THEN 'TIMESTAMP WITH TIME ZONE'
        WHEN DBMS_TYPES.TYPECODE_TIMESTAMP_LTZ THEN 'TIMESTAMP WITH LOCAL TIME ZONE'
        WHEN DBMS_TYPES.TYPECODE_INTERVAL_YM   THEN 'INTERVAL YEAR TO MONTH'
        WHEN DBMS_TYPES.TYPECODE_INTERVAL_DS   THEN 'INTERVAL DAY TO SECOND'
        WHEN DBMS_TYPES.TYPECODE_NCHAR         THEN 'NCHAR'
        WHEN DBMS_TYPES.TYPECODE_NVARCHAR2     THEN 'NVARCHAR2'
        WHEN DBMS_TYPES.TYPECODE_NCLOB         THEN 'NCLOB'
        WHEN DBMS_TYPES.TYPECODE_BFLOAT        THEN 'BINARY_FLOAT'
        WHEN DBMS_TYPES.TYPECODE_BDOUBLE       THEN 'BINARY_DOUBLE'
        WHEN DBMS_TYPES.TYPECODE_UROWID        THEN 'UROWID'
      END;
  END;
  MEMBER FUNCTION get_anydata_proc_suffix return VARCHAR2 IS
  BEGIN
    RETURN
    CASE SELF.type_code
      WHEN DBMS_TYPES.TYPECODE_DATE            THEN 'Date'
      WHEN DBMS_TYPES.TYPECODE_NUMBER          THEN 'Number'
      WHEN DBMS_TYPES.TYPECODE_RAW             THEN 'Raw'
      WHEN DBMS_TYPES.TYPECODE_CHAR            THEN 'Char'
      WHEN DBMS_TYPES.TYPECODE_VARCHAR2        THEN 'Varchar2'
      WHEN DBMS_TYPES.TYPECODE_VARCHAR         THEN 'Varchar'
      WHEN DBMS_TYPES.TYPECODE_BLOB            THEN 'Blob'
      WHEN DBMS_TYPES.TYPECODE_BFILE           THEN 'Bfile'
      WHEN DBMS_TYPES.TYPECODE_CLOB            THEN 'Clob'
      WHEN DBMS_TYPES.TYPECODE_CFILE           THEN 'Cfile'
      WHEN DBMS_TYPES.TYPECODE_TIMESTAMP       THEN 'Timestamp'
      WHEN DBMS_TYPES.TYPECODE_TIMESTAMP_TZ    THEN 'TimestampTZ'
      WHEN DBMS_TYPES.TYPECODE_TIMESTAMP_LTZ   THEN 'TimestampLTZ'
      WHEN DBMS_TYPES.TYPECODE_INTERVAL_YM     THEN 'IntervalYM'
      WHEN DBMS_TYPES.TYPECODE_INTERVAL_DS     THEN 'IntervalDS'
      WHEN DBMS_TYPES.TYPECODE_NCHAR           THEN 'Nchar'
      WHEN DBMS_TYPES.TYPECODE_NVARCHAR2       THEN 'Nvarchar2'
      WHEN DBMS_TYPES.TYPECODE_NCLOB           THEN 'NClob'
      WHEN DBMS_TYPES.TYPECODE_BFLOAT          THEN 'BFloat'
      WHEN DBMS_TYPES.TYPECODE_BDOUBLE         THEN 'BDouble'
      WHEN DBMS_TYPES.TYPECODE_OBJECT          THEN 'Object'
      WHEN DBMS_TYPES.TYPECODE_VARRAY          THEN 'Collection'
      WHEN DBMS_TYPES.TYPECODE_TABLE           THEN 'Collection'
      WHEN DBMS_TYPES.TYPECODE_NAMEDCOLLECTION THEN 'Collection'
    END;
  END;
  MEMBER FUNCTION anydata_getter  RETURN VARCHAR2 IS
  BEGIN
    RETURN 'get'||get_anydata_proc_suffix;
  END;
  MEMBER FUNCTION anydata_converter  RETURN VARCHAR2 IS
  BEGIN
    RETURN 'convert'||get_anydata_proc_suffix;
  END;

  MEMBER PROCEDURE update_from_attribute_type(SELF IN OUT NOCOPY anytype_info) IS
    v_name_lst      DBMS_UTILITY.MAXNAME_ARRAY;
    BEGIN
      IF SELF.attribute_type IS NOT NULL THEN
        SELF.type_code := SELF.attribute_type.GETINFO(
            SELF.prec,
            SELF.scale,
            SELF.len,
            SELF.csid,
            SELF.csfrm,
            SELF.schema_name,
            SELF.type_name,
            SELF.version,
            SELF.count);
      ELSE
        SELF.map_typecode_to_typename();
      END IF;
    END;

  CONSTRUCTOR FUNCTION anytype_info( pv_attribute_name VARCHAR2, pv_value ANYDATA) RETURN SELF AS RESULT IS
    BEGIN
      SELF.attribute_name := UPPER( pv_attribute_name );
      SELF.type_code := pv_value.gettype( SELF.attribute_type );
      SELF.update_from_attribute_type();
      RETURN;
    END;

  CONSTRUCTOR FUNCTION anytype_info( pv_child_position PLS_INTEGER, pv_parent_type ANYTYPE) RETURN SELF AS RESULT IS
    BEGIN
      IF pv_parent_type IS NOT NULL THEN
        SELF.type_code := pv_parent_type.getAttrElemInfo(
            pv_child_position,
            SELF.prec,
            SELF.scale,
            SELF.len,
            SELF.csid,
            SELF.csfrm,
            SELF.attribute_type,
            SELF.attribute_name
        );
        SELF.update_from_attribute_type();
      END IF;
      RETURN;
    END;

  MEMBER FUNCTION get_child_type_info( pv_child_position PLS_INTEGER ) RETURN anytype_info IS
    BEGIN
      RETURN anytype_info( pv_child_position, SELF.attribute_type );
    END;

  MEMBER FUNCTION get_typename RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN schema_name IS NULL THEN type_name ELSE schema_name||'.'||type_name END;
  END;
  MEMBER FUNCTION get_report RETURN VARCHAR2 IS
    BEGIN
      RETURN
        CASE WHEN attribute_name IS NOT NULL OR schema_name IS NOT NULL THEN
          attribute_name || '(' || type_name
            || CASE
               WHEN prec IS NOT NULL AND NOT ( prec = 0 AND NVL(scale,0) = -127 ) THEN
                 '(' || prec || CASE WHEN scale IS NOT NULL THEN ',' || scale END || ')'
               WHEN len IS NOT NULL THEN
                 '(' || len || ')'
              END
            || ')'
            || ' => '
        END;
    END;
  MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN 'attribute_name=> '||SELF.attribute_name||'
attribute_type => '||CASE WHEN SELF.attribute_type IS NULL THEN 'NULL' ELSE 'NOT NULL' END||'
prec          => '||SELF.prec          ||'
scale         => '||SELF.scale         ||'
len           => '||SELF.len           ||'
csid          => '||SELF.csid          ||'
csfrm         => '||SELF.csfrm         ||'
schema_name   => '||SELF.schema_name   ||'
type_name     => '||SELF.type_name     ||'
version       => '||SELF.version       ||'
type_code     => '||SELF.type_code     ||'
count         => '||SELF.count;
    END;
END;
/

