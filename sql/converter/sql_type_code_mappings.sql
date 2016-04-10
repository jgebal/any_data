--inspired by https://ellebaek.wordpress.com/2011/02/25/oracle-type-code-mappings/
create table sql_type_code_mappings (
   dbms_sql_typecode         int,
   dbms_types_type_code      int,
   constraint sql_type_code_mappings_pk primary key (dbms_sql_typecode),
   constraint sql_type_code_mappings_fk1 foreign key (dbms_types_type_code) references dbms_type_code_mappings(dbms_types_type_code)
);

begin
   merge into sql_type_code_mappings dst
      using (  select dbms_types.typecode_bdouble as dbms_types_type_code, dbms_sql.binary_bouble_type as dbms_sql_typecode from dual union all
               select dbms_types.typecode_bfile, dbms_sql.bfile_type from dual union all
               select dbms_types.typecode_bfloat, dbms_sql.binary_float_type from dual union all
               select dbms_types.typecode_blob, dbms_sql.blob_type from dual union all
               select dbms_types.typecode_raw, dbms_sql.long_raw_type from dual union all
--               select dbms_types.typecode_cfile, null from dual union all
               select dbms_types.typecode_char, dbms_sql.char_type from dual union all
               select dbms_types.typecode_clob, dbms_sql.clob_type from dual union all
               select dbms_types.typecode_varchar2, dbms_sql.long_type from dual union all
               select dbms_types.typecode_date, dbms_sql.date_type from dual union all
               select dbms_types.typecode_interval_ds, dbms_sql.interval_day_to_second_type from dual union all
               select dbms_types.typecode_interval_ym, dbms_sql.interval_year_to_month_type from dual union all
               select dbms_types.typecode_raw, dbms_sql.raw_type from dual union all
               select dbms_types.typecode_timestamp, dbms_sql.timestamp_type from dual union all
               select dbms_types.typecode_timestamp_tz, dbms_sql.timestamp_with_tz_type from dual union all
               select dbms_types.typecode_timestamp_ltz, dbms_sql.timestamp_with_local_tz_type from dual union all
               select dbms_types.typecode_varchar2, dbms_sql.varchar2_type from dual union all
               select dbms_types.typecode_number, dbms_sql.number_type from dual
            ) src
   on (src.dbms_types_type_code = dst.dbms_types_type_code)
   when not matched then
   insert ( dbms_sql_typecode, dbms_types_type_code )
   values ( src.dbms_sql_typecode, src.dbms_types_type_code );
   commit;
end;
/
