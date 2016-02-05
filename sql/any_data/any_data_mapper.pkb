create or replace package body any_data_mapper as

--    function get_by_typecode( p_type_code integer, p_data anydata ) return any_data is
--       begin
--          return
--          case
--          when p_type_code = dbms_types.typecode_number
--             then any_data_number( p_data )
--          when p_type_code = dbms_types.typecode_object
--             then any_data_object( p_data )
--          when p_type_code in
--               ( dbms_types.typecode_varray, dbms_types.typecode_table, dbms_types.typecode_namedcollection )
--             then any_data_collection( p_type_code, p_data )
--          end;
--       end;
--
   type any_data_map_type is table of any_data index by binary_integer;

   mapper_table any_data_map_type;

   function get_by_typecode( p_type_code integer ) return any_data is
      begin
         return mapper_table(p_type_code);
         exception when others then
         dbms_output.put_line('could not get type for p_type_code ='||p_type_code);
         raise;
      end;

begin
   mapper_table( dbms_types.typecode_number ) := any_data_number();
   mapper_table( dbms_types.typecode_object ) := any_data_object();
   mapper_table( dbms_types.typecode_varray ) := any_data_collection( dbms_types.typecode_varray );
   mapper_table( dbms_types.typecode_table )  := any_data_collection( dbms_types.typecode_table );
   mapper_table( dbms_types.typecode_namedcollection )  := any_data_collection( dbms_types.typecode_namedcollection );
   --    mapper_table( dbms_types.typecode_date )
   --    := any_data( 'Date', 'to_char( ' || anydata_helper.value_var || ', ''YYYY-MM-DD HH24:MI:SS'')' );
   --    mapper_table( dbms_types.typecode_timestamp )
   --    := any_data( 'Timestamp', 'to_char(' || anydata_helper.value_var || ',''YYYY-MM-DD HH24:MI:SSxFF TZH:TZM'')' );
   --    mapper_table( dbms_types.typecode_timestamp_tz )
   --    := any_data( 'TimestampTZ', 'to_char(' || anydata_helper.value_var || ',''YYYY-MM-DD HH24:MI:SSxFF TZH:TZM'')' );
   --    mapper_table( dbms_types.typecode_timestamp_ltz )
   --    := any_data( 'TimestampLTZ', 'to_char(' || anydata_helper.value_var || ',''YYYY-MM-DD HH24:MI:SSxFF TZH:TZM'')' );
   --    mapper_table( dbms_types.typecode_interval_ym )
   --    := any_data( 'IntervalYM', 'to_char(' || anydata_helper.value_var || ')' );
   --    mapper_table( dbms_types.typecode_interval_ds )
   --    := any_data( 'IntervalDS', 'to_char(' || anydata_helper.value_var || ')' );
   --    mapper_table( dbms_types.typecode_char )
   --    := anydata_char( 'Char' );
   --    mapper_table( dbms_types.typecode_varchar2 )
   --    := anydata_char( 'Varchar2' );
   --    mapper_table( dbms_types.typecode_varchar )
   --    := anydata_char( 'Varchar' );
   --    mapper_table( dbms_types.typecode_nchar )
   --    := anydata_char( 'Nchar' );
   --    mapper_table( dbms_types.typecode_nvarchar2 )
   --    := anydata_char( 'NVarchar2' );
   --    mapper_table( dbms_types.typecode_raw )
   --    := any_data( 'Raw', 'utl_raw.cast_to_varchar2(' || anydata_helper.value_var || ')' );
   --    mapper_table( dbms_types.typecode_blob )
   --    := any_data( 'Blob', 'utl_raw.cast_to_varchar2(dbms_lob.substr(' || anydata_helper.value_var || ',' ||
   --                         anydata_helper.max_return_data_length || '))' );
   --    mapper_table( dbms_types.typecode_bfile )
   --    := any_data( 'Bfile', 'utl_raw.cast_to_varchar2(dbms_lob.substr(' || anydata_helper.value_var || ',' ||
   --                          anydata_helper.max_return_data_length || '))' );
   --    mapper_table( dbms_types.typecode_clob )
   --    := any_data( 'Clob',
   --                 'to_char(dbms_lob.substr(' || anydata_helper.value_var || ',' || anydata_helper.max_return_data_length
   --                 || '))' );
   --    mapper_table( dbms_types.typecode_cfile )
   --    := any_data( 'Cfile',
   --                 'dbms_lob.substr(' || anydata_helper.value_var || ',' || anydata_helper.max_return_data_length || ')' );
   --    mapper_table( dbms_types.typecode_nclob )
   --    := any_data( 'NClob',
   --                 'to_char(dbms_lob.substr(' || anydata_helper.value_var || ',' || anydata_helper.max_return_data_length
   --                 || '))' );
   --    mapper_table( dbms_types.typecode_bfloat )
   --    := any_data( 'BFloat', 'to_char(' || anydata_helper.value_var || ')' );
   --    mapper_table( dbms_types.typecode_bdouble )
   --    := any_data( 'BDouble', 'to_char(' || anydata_helper.value_var || ')' );
end;
/
