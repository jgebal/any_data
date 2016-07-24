--inspired by https://ellebaek.wordpress.com/2011/02/25/oracle-type-code-mappings/
begin
   merge into dbms_type_code_mappings dst
      using (  select dbms_types.typecode_bdouble as dbms_types_type_code, 'any_data_bdouble' as any_data_object_name, to_number(null) as max_precision, to_number(null) as max_scale, to_number(null) as max_length, 'BINARY_DOUBLE' as type_declaration_template from dual union all
               select dbms_types.typecode_bfile, 'any_data_bfile', null, null, null, 'BFILE' from dual union all
               select dbms_types.typecode_bfloat, 'any_data_bfloat', null, null, null, 'BINARY_FLOAT' from dual union all
               select dbms_types.typecode_blob, 'any_data_blob', null, null, null, 'BLOB' from dual union all
               select dbms_types.typecode_cfile, 'any_data_cfile', null, null, null, 'CFILE' from dual union all
               select dbms_types.typecode_char, 'any_data_char', null, null, 32767, 'CHAR{length}' from dual union all
               select dbms_types.typecode_clob, 'any_data_clob', null, null, null, 'CLOB' from dual union all
               select dbms_types.typecode_varray, 'any_data_collection', null, null, null, 'VARRAY' from dual union all
               select dbms_types.typecode_table, 'any_data_collection', null, null, null, 'TABLE' from dual union all
               select dbms_types.typecode_namedcollection, 'any_data_collection', null, null, null, 'COLLECTION' from dual union all
               select dbms_types.typecode_date, 'any_data_date', null, null, null, 'DATE' from dual union all
               select dbms_types.typecode_interval_ds, 'any_data_interval_ds', 9, 9, null, 'INTERVAL DAY{precision} TO SECOND{scale}' from dual union all
               select dbms_types.typecode_interval_ym, 'any_data_interval_ym', 9, null, null, 'INTERVAL YEAR{precision} TO MONTH' from dual union all
               select dbms_types.typecode_nchar, 'any_data_nchar', null, null, 32767, 'NCHAR{length}' from dual union all
               select dbms_types.typecode_nclob, 'any_data_nclob', null, null, null, 'NCLOB' from dual union all
               select dbms_types.typecode_nvarchar2, 'any_data_nvarchar2', null, null, 32767, 'NVARCHAR2{length}' from dual union all
               select dbms_types.typecode_object, 'any_data_object', null, null, null, 'OBJECT' from dual union all
               select dbms_types.typecode_raw, 'any_data_raw', null, null, 32767, 'RAW{length}' from dual union all
               select dbms_types.typecode_timestamp, 'any_data_timestamp', null, 9, null, 'TIMESTAMP{scale}' from dual union all
               select dbms_types.typecode_timestamp_tz, 'any_data_timestamp_tz', null, 9, null, 'TIMESTAMP{scale} WITH TIME ZONE' from dual union all
               select dbms_types.typecode_timestamp_ltz, 'any_data_timestamp_ltz', null, 9, null, 'TIMESTAMP{scale} WITH LOCAL TIME ZONE' from dual union all
               select dbms_types.typecode_varchar, 'any_data_varchar', null, null, 32767, 'VARCHAR{length}' from dual union all
               select dbms_types.typecode_varchar2, 'any_data_varchar2', null, null, 32767, 'VARCHAR2{length}' from dual union all
               select dbms_types.typecode_number, 'any_data_number', null, null, null, 'NUMBER{precision_scale}' from dual union all
               select 3 /*INTEGER*/, 'any_data_number', null, null, null, 'INTEGER{precision}' from dual union all
               select 246 /*SMALLINT*/, 'any_data_number', null, null, null, 'SMALLINT{precision}' from dual

            ) src
   on (src.dbms_types_type_code = dst.dbms_types_type_code)
   when not matched then
   insert ( dbms_types_type_code, any_data_object_name, max_precision, max_scale, max_length, type_declaration_template )
   values ( src.dbms_types_type_code, src.any_data_object_name, src.max_precision, src.max_scale, src.max_length, src.type_declaration_template );
   commit;
end;
/
