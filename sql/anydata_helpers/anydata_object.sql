drop type anydata_object force;
/

create or replace type anydata_object under anydata_base (
constructor function anydata_object return self as result,
overriding member function get_sql_for_value_string return varchar2,
member function get_sql_for_attribute( pv_position integer ) return varchar2,
overriding member function get_report return varchar2
);
/

create or replace type body anydata_object as

   constructor function anydata_object return self as result is
      begin
         self.initialize( 'Object',
                          anydata_helper.to_sting_placeholder
         );
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
               v_anydata.piecewise();';
         for i in 1 .. element_anytype_info.count loop
            v_sql := v_sql || get_sql_for_attribute( i );
            v_sql := v_sql || case
               when self.element_anytype_info.count != i
               then '
               v_result := v_result || '','' || anydata_helper.new_line;'
               end;
         end loop;

         v_sql := v_sql || '
               :p_result := ' || replace( string_data_getter, anydata_helper.to_sting_placeholder, 'v_result' ) || ';
            end;';
         return v_sql;
      end;

member function get_sql_for_attribute( pv_position integer ) return varchar2 is
      v_attribute_type_info anytype_info;
      v_attribute_anydata   anydata_base;
      begin
         v_attribute_type_info := self.get_child_type_info( pv_position );
         v_attribute_anydata := anydata_base.construct( v_attribute_type_info.type_code );
         v_attribute_anydata.element_anytype_info := v_attribute_type_info;
         return
         replace(
            replace(
               v_attribute_anydata.get_sql_for_piecewise_string( ),
               anydata_helper.piecewise_pos_placeholder,
               pv_position
            ),
            anydata_helper.typecode_placeholder,
            v_attribute_type_info.type_code
         );
      end;

overriding member function get_report return varchar2 is
      begin
         return self.element_name
                || '(' || self.get_type_name( ) || ')' || ' => ' || '{' || anydata_helper.new_line
                || anydata_helper.indent_lines( self.get_value_as_string( ) ) || anydata_helper.new_line
                || '}';
      end;

end;
/
