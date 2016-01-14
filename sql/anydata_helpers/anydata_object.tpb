create or replace type body anydata_object as

   constructor function anydata_object return self as result is
      begin
         self.initialize( 'Object' );
         return;
      end;

overriding member function get_elements_sql return varchar2 is
      v_sql varchar2(32767);
      begin
         v_sql := '
            declare
               v_anydata_base      anydata_base := :p_in_data;
               v_anydata           anydata := v_anydata_base.element_raw_data;
               v_result            anydata_base_arr := anydata_base_arr();
               v_attribute_anydata anydata_base;
            begin
               v_anydata.piecewise();';
         for i in 1 .. self.type_info.count loop
            v_sql := v_sql
               || self.get_sql_for_attribute( i )
               || '
               v_result.extend;
               v_result( v_result.last ) := v_attribute_anydata;';
         end loop;
         v_sql := v_sql || '
               :p_result := v_result;
            end;';
         return v_sql;
      end;

overriding member function get_report return varchar2 is
      begin
         return self.element_name
                || '(' || self.get_type( ) || ')' || ' => ' || '{' || anydata_helper.new_line
                || anydata_helper.indent_lines( self.get_value_as_string( ) ) || anydata_helper.new_line
                || '}';
      end;

end;
/
