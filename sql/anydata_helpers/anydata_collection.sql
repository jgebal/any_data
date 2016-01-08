drop type anydata_collection force;
/

create or replace type anydata_collection under anydata_compound (
constructor function anydata_collection return self as result,
overriding member function get_sql_for_value_string return varchar2,
overriding member function get_report return varchar2
);
/

create or replace type body anydata_collection as

   constructor function anydata_collection return self as result is
      begin
         self.initialize( 'Object' );
         return;
      end;

overriding member function get_sql_for_value_string return varchar2 is
      v_sql varchar2(32767);
      begin
         v_sql := '
            declare
               v_anydata_base      anydata_base := :p_in_data;
               v_anydata           anydata := v_anydata_base.element_raw_data;
               v_result            varchar2(32767);
               v_attribute_anydata anydata_base;
            begin
               v_anydata.piecewise();
               loop
                  begin'
                  || self.get_sql_for_attribute( 1 ) || '
                  v_result := v_result || '','' || anydata_helper.new_line;
                  exception
                     when no_data_found then
                        :p_result := rtrim( v_result, '','' || anydata_helper.new_line ) ;
                        exit;
                  end;
               end loop;
            end;';
         return v_sql;
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
