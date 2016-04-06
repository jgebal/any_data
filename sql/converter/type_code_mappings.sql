create table type_code_mappings (
   dbms_types_type_code      int,
   dbms_sql_typecode         int,
   any_data_object_name      varchar2(100),
   anydata_getter as( replace( replace( any_data_object_name, 'any_data_' ), '_' ) ),
   max_precision             int,
   max_scale                 int,
   max_length                int,
   type_declaration_template varchar2(100),
   build_in_type_name as ( regexp_replace( type_declaration_template, '\{[precision|scale|precision_scale|length]*\}', '' ) ),
   max_type_declaration as (
   replace(
      replace(
         replace(
            replace( type_declaration_template, '{precision}',nvl2( max_precision, '(' || max_precision || ')', null )),
            '{scale}',
            nvl2( max_scale, '(' || max_scale || ')', null )
         ),
         '{length}',
         nvl2( max_length, '(' || max_length || ')', null )
      ),
      '{precision_scale}',
      nvl2( max_precision||max_scale, '(' || max_precision||'.'||max_scale|| ')', null )
   )
   ),
   CONSTRAINT type_code_mappings_pk PRIMARY KEY (dbms_types_type_code),
   CONSTRAINT type_code_mappings_uk1 UNIQUE (dbms_sql_typecode)
);

begin
   merge into type_code_mappings dst
      using (  select dbms_types.typecode_bdouble as dbms_types_type_code, dbms_sql.binary_bouble_type as dbms_sql_typecode, 'any_data_bdouble' as any_data_object_name, to_number(null) as max_precision, to_number(null) as max_scale, to_number(null) as max_length, 'BINARY_DOUBLE' as type_declaration_template from dual union all
               select dbms_types.typecode_bfile, dbms_sql.bfile_type, 'any_data_bfile', null, null, null, 'BFILE' from dual union all
               select dbms_types.typecode_bfloat, dbms_sql.binary_float_type, 'any_data_bfloat', null, null, null, 'BINARY_FLOAT' from dual union all
               select dbms_types.typecode_blob, dbms_sql.blob_type, 'any_data_blob', null, null, null, 'BLOB' from dual union all
               select dbms_types.typecode_cfile, null, 'any_data_cfile', null, null, null, 'CFILE' from dual union all
               select dbms_types.typecode_char, dbms_sql.char_type, 'any_data_char', null, null, 32767, 'CHAR{length}' from dual union all
               select dbms_types.typecode_clob, dbms_sql.clob_type, 'any_data_clob', null, null, null, 'CLOB' from dual union all
               select dbms_types.typecode_varray, null, 'any_data_collection', null, null, null, 'VARRAY' from dual union all
               select dbms_types.typecode_table, null, 'any_data_collection', null, null, null, 'TABLE' from dual union all
               select dbms_types.typecode_namedcollection, null, 'any_data_collection', null, null, null, 'COLLECTION' from dual union all
               select dbms_types.typecode_date, dbms_sql.date_type, 'any_data_date', null, null, null, 'DATE' from dual union all
               select dbms_types.typecode_interval_ds, dbms_sql.interval_day_to_second_type, 'any_data_interval_ds', 9, 9, null, 'INTERVAL DAY{precision} TO SECOND{scale}' from dual union all
               select dbms_types.typecode_interval_ym, dbms_sql.interval_year_to_month_type, 'any_data_interval_ym', 9, null, null, 'INTERVAL YEAR{precision} TO MONTH' from dual union all
               select dbms_types.typecode_nchar, null, 'any_data_nchar', null, null, 32767, 'NCHAR{length}' from dual union all
               select dbms_types.typecode_nclob, null, 'any_data_nclob', null, null, null, 'NCLOB' from dual union all
               select dbms_types.typecode_nvarchar2, null, 'any_data_nvarchar2', null, null, 32767, 'NVARCHAR2{length}' from dual union all
               select dbms_types.typecode_object, null, 'any_data_object', null, null, null, 'OBJECT' from dual union all
               select dbms_types.typecode_raw, dbms_sql.raw_type, 'any_data_raw', null, null, 32767, 'RAW{length}' from dual union all
               select dbms_types.typecode_timestamp, dbms_sql.timestamp_type, 'any_data_timestamp', null, 9, null, 'TIMESTAMP{scale}' from dual union all
               select dbms_types.typecode_timestamp_tz, dbms_sql.timestamp_with_tz_type, 'any_data_timestamp_tz', null, 9, null, 'TIMESTAMP{scale} WITH TIME ZONE' from dual union all
               select dbms_types.typecode_timestamp_ltz, dbms_sql.timestamp_with_local_tz_type, 'any_data_timestamp_ltz', null, 9, null, 'TIMESTAMP{scale} WITH LOCAL TIME ZONE' from dual union all
               select dbms_types.typecode_varchar, null, 'any_data_varchar', null, null, 32767, 'VARCHAR{length}' from dual union all
               select dbms_types.typecode_varchar2, dbms_sql.varchar2_type, 'any_data_varchar2', null, null, 32767, 'VARCHAR2{length}' from dual union all
               select dbms_types.typecode_number, dbms_sql.number_type, 'any_data_number', null, null, null, 'NUMBER{precision_scale}' from dual union all
               select 3 /*INTEGER*/, null, 'any_data_number', null, null, null, 'INTEGER{precision}' from dual union all
               select 246 /*SMALLINT*/, null, 'any_data_number', null, null, null, 'SMALLINT{precision}' from dual

            ) src
   on (src.dbms_types_type_code = dst.dbms_types_type_code)
   when not matched then
   insert ( dbms_types_type_code, dbms_sql_typecode, any_data_object_name, max_precision, max_scale, max_length, type_declaration_template )
   values ( src.dbms_types_type_code, src.dbms_sql_typecode, src.any_data_object_name, src.max_precision, src.max_scale, src.max_length, src.type_declaration_template );
   commit;
end;
/
