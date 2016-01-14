create or replace type body anydata_compound as

member procedure initialize( p_function_suffix varchar2 ) is
      begin
         self.initialize( p_function_suffix, anydata_helper.value_var );
      end;

member function get_sql_for_attribute( p_position integer := null ) return varchar2 is
      v_attribute_type_info anytype_info;
      v_attribute_anydata   anydata_base;
      begin
         v_attribute_type_info := self.get_child_type_info( p_position );
         v_attribute_anydata := anydata_base.construct( v_attribute_type_info.type_code );
         v_attribute_anydata.type_info := v_attribute_type_info;
         return
               v_attribute_anydata.construct_as_attribute_sql( v_attribute_type_info.type_code, p_position );
      end;

overriding final member function get_value_as_string
   return varchar2 is
   v_result   varchar2(32767);
   v_elements anydata_base_arr;
   begin
      --      return get_elements_sql();
      execute immediate get_elements_sql() using self, out v_elements;
      for i in 1 .. cardinality(v_elements) loop
         v_result := v_result || v_elements(i).get_report() || ',' || anydata_helper.new_line ;
      end loop;
      return rtrim( v_result, ',' || anydata_helper.new_line );
   end;

end;
/
