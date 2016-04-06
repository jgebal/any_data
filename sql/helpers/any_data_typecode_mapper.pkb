create or replace package body any_data_typecode_mapper as

   function get_dbms_types_mapping( p_type_code binary_integer ) return type_code_mappings%rowtype result_cache is
      v_result type_code_mappings%rowtype;
      begin
         select *
         into v_result
         from type_code_mappings m
         where m.dbms_types_type_code = p_type_code;
         return v_result;
      exception when no_data_found then
         raise_application_error( -20000, 'Unsupported typecode = '|| p_type_code );
      end;

   function get_dbms_sql_mapping( p_dbms_sql_typecode binary_integer ) return type_code_mappings%rowtype result_cache is
      v_result type_code_mappings%rowtype;
      begin
         select *
         into v_result
         from type_code_mappings m
         where m.dbms_sql_typecode = p_dbms_sql_typecode;
         return v_result;
      exception when no_data_found then
         raise_application_error( -20001, 'Unsupported sql type code = '|| p_dbms_sql_typecode );
      end;

end;
/



