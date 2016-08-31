create or replace package body any_data_typecode_mapper as

   function get_dbms_types_mapping( p_type_code binary_integer ) return dbms_type_code_mappings%rowtype result_cache deterministic is
      v_result dbms_type_code_mappings%rowtype;
      begin
         select m.*
         into v_result
         from dbms_type_code_mappings m
         where m.dbms_types_type_code = p_type_code;
         return v_result;
      exception when no_data_found then
         raise_application_error( -20000, 'Unsupported typecode = '|| p_type_code );
      end;

   function get_dbms_sql_mapping( p_dbms_sql_typecode binary_integer ) return dbms_type_code_mappings%rowtype result_cache deterministic is
      v_result dbms_type_code_mappings%rowtype;
      begin
         select m.*
         into v_result
         from dbms_type_code_mappings m
         join sql_type_code_mappings s
            on s.dbms_types_type_code = m.dbms_types_type_code
         where s.dbms_sql_typecode = p_dbms_sql_typecode;
         return v_result;
      exception when no_data_found then
         raise_application_error( -20001, 'Unsupported sql type code = '|| p_dbms_sql_typecode );
      end;

end;
/



