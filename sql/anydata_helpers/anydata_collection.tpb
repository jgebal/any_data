create or replace type body anydata_collection as

   constructor function anydata_collection return self as result is
      begin
         self.initialize( 'Collection' );
         return;
      end;

overriding member function get_elements_sql return varchar2 is
   begin
      return '
            declare
               v_anydata_base      anydata_base := :p_in_data;
               v_anydata           anydata := v_anydata_base.element_raw_data;
               v_result            anydata_base_arr := anydata_base_arr();
               v_attribute_anydata anydata_base;
               '||anydata_helper.value_var||' ' || self.get_type_def( ) || ';
               i                   integer;
            begin
               ' || self.get_data_getter_sql( ) || '
               i := '||anydata_helper.value_var||'.first;
               while i is not null loop'
                  || self.get_sql_for_attribute( ) || '
                  v_result.extend;
                  v_result( v_result.last ) := v_attribute_anydata;
                  i := '||anydata_helper.value_var||'.next(i);
               end loop;
               :p_resput := v_result;
            end;';
   end;

overriding member function get_report return varchar2 is
      begin
         return self.element_name
                || '(' || self.get_type( ) || ')' || ' => ' || '[' || anydata_helper.new_line
                || anydata_helper.indent_lines( self.get_value_as_string( ) ) || anydata_helper.new_line
                || ']';
      end;

end;
/
