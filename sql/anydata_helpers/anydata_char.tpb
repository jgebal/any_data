create or replace type body anydata_char as

   constructor function anydata_char( p_function_suffix varchar2 ) return self as result is
      begin
         self.initialize(
            p_function_suffix,
            --need trim as anydata returns a char 32767 from any convert from CHAR datatype
            'substr(trim('||anydata_helper.value_var||'),1,'||(anydata_helper.max_return_data_length - 2)||')'
         );
         return;
      end;

overriding member function get_type_def return varchar2 is
      v_parent_type varchar2(120) := ( self as anydata_base ).get_type_def( );
      begin
         return
         case
         when v_parent_type not like '%(%)%'
            then v_parent_type || '(32767)'
         else v_parent_type
         end;
      end;

overriding member function get_value_as_string return varchar2 is
      begin
         return '''' || ( self as anydata_base ).get_value_as_string( ) || '''';
      end;

end;
/
