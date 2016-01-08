drop type anydata_char force;
/

create or replace type anydata_char under anydata_base (
constructor function anydata_char return self as result,
member procedure initialize( p_function_suffix varchar2 ),
overriding member function get_type_def return varchar2,
overriding member function get_value_as_string return varchar2
) not final;
/

create or replace type body anydata_char as

   constructor function anydata_char return self as result is
      begin
         initialize( 'Char' );
         return;
      end;

member procedure initialize( p_function_suffix varchar2 ) is
      begin
         self.initialize(
            p_function_suffix,
            anydata_helper.substr(
            --need trim as anydata returns a char 32767 from any convert from CHAR datatype
               anydata_helper.trim(
                  anydata_helper.to_sting_placeholder
               ),
               1,
               anydata_helper.max_return_data_length - 2
            )
         );
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
