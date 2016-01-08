drop type anydata_compound force;
/

create or replace type anydata_compound under anydata_base (
member procedure initialize( p_function_suffix varchar2 ),
member function get_sql_for_attribute( pv_position integer ) return varchar2
) not final not instantiable;
/

create or replace type body anydata_compound as

member procedure initialize( p_function_suffix varchar2 ) is
      begin
         self.initialize( p_function_suffix, anydata_helper.to_sting_placeholder );
      end;

member function get_sql_for_attribute( pv_position integer ) return varchar2 is
      v_attribute_type_info anytype_info;
      v_attribute_anydata   anydata_base;
      begin
         v_attribute_type_info := self.get_child_type_info( pv_position );
         v_attribute_anydata := anydata_base.construct( v_attribute_type_info.type_code );
         v_attribute_anydata.type_info := v_attribute_type_info;
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

end;
/
