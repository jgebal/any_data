create or replace package body anytype_map as

   type anydata_helper_base_lst is table of anydata_helper_base index by binary_integer;

   anydata_helper_map anydata_helper_base_lst;

   function get_element( p_typecode integer )
      return anydata_helper_base is
      begin
         return anydata_helper_map( p_typecode );
      end;
begin
   anydata_helper_map( DBMS_TYPES.TYPECODE_DATE ) := anydata_helper_date();
   anydata_helper_map( DBMS_TYPES.TYPECODE_NUMBER ) := anydata_helper_number();
   anydata_helper_map( DBMS_TYPES.TYPECODE_RAW ) := anydata_helper_raw();
   anydata_helper_map( DBMS_TYPES.TYPECODE_CHAR ) := anydata_helper_char();
   anydata_helper_map( DBMS_TYPES.TYPECODE_VARCHAR2 ) := anydata_helper_varchar2();
   anydata_helper_map( DBMS_TYPES.TYPECODE_VARCHAR ) := anydata_helper_varchar();
   anydata_helper_map( DBMS_TYPES.TYPECODE_BLOB ) := anydata_helper_blob();
   anydata_helper_map( DBMS_TYPES.TYPECODE_BFILE ) := anydata_helper_bfile();
   anydata_helper_map( DBMS_TYPES.TYPECODE_CLOB ) := anydata_helper_clob();
   anydata_helper_map( DBMS_TYPES.TYPECODE_CFILE ) := anydata_helper_cfile();
   anydata_helper_map( DBMS_TYPES.TYPECODE_TIMESTAMP ) := anydata_helper_timestamp();
   anydata_helper_map( DBMS_TYPES.TYPECODE_TIMESTAMP_TZ ) := anydata_helper_timestamp_tz();
   anydata_helper_map( DBMS_TYPES.TYPECODE_TIMESTAMP_LTZ ) := anydata_helper_timestamp_ltz();
   anydata_helper_map( DBMS_TYPES.TYPECODE_INTERVAL_YM ) := anydata_helper_interval_ym();
   anydata_helper_map( DBMS_TYPES.TYPECODE_INTERVAL_DS ) := anydata_helper_interval_ds();
   anydata_helper_map( DBMS_TYPES.TYPECODE_NCHAR ) := anydata_helper_nchar();
   anydata_helper_map( DBMS_TYPES.TYPECODE_NVARCHAR2 ) := anydata_helper_nvarchar2();
   anydata_helper_map( DBMS_TYPES.TYPECODE_NCLOB ) := anydata_helper_nclob();
   anydata_helper_map( DBMS_TYPES.TYPECODE_BFLOAT ) := anydata_helper_bfloat();
   anydata_helper_map( DBMS_TYPES.TYPECODE_BDOUBLE ) := anydata_helper_bdouble();
   anydata_helper_map( DBMS_TYPES.TYPECODE_OBJECT ) := anydata_helper_object();
   anydata_helper_map( DBMS_TYPES.TYPECODE_VARRAY ) := anydata_helper_collection();
   anydata_helper_map( DBMS_TYPES.TYPECODE_TABLE ) := anydata_helper_collection();
   anydata_helper_map( DBMS_TYPES.TYPECODE_NAMEDCOLLECTION ) := anydata_helper_collection();
end;
/

   
