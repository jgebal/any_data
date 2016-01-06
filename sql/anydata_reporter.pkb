create or replace package body anydata_reporter is

   function get_report( p_field_name varchar2, p_field_value anydata, p_indent integer := 0 )
      return varchar2 is
      v_field_value anydata := p_field_value;
      v_anydata_helper anydata_helper_base;
      begin
         v_anydata_helper := anydata_helper_base.construct( p_field_name, v_field_value );
         return v_anydata_helper.get_report( );
      end;

end;
/
