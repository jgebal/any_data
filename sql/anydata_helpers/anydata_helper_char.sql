drop type anydata_helper_char force;
/

create or replace type anydata_helper_char under anydata_helper_base (
   member procedure initialize( p_function_suffix varchar2),
   overriding member function get_type_string return varchar2,
   constructor function anydata_helper_char return self as result
) not final;
/

create or replace type body anydata_helper_char as
   member procedure initialize( p_function_suffix varchar2 ) is
      begin
         self.initialize(
            p_function_suffix,
            '''"''||'
            || dyn_sql_helper.substr(
                  --need trim as anydata returns a char 32767 from any convert from CHAR datatype
                  dyn_sql_helper.trim(
                     dyn_sql_helper.to_sting_placeholder
                  ),
                  1,
                  dyn_sql_helper.max_return_data_length - 2
               )
            || '||''"'''
         );
      end;
   constructor function anydata_helper_char return self as result is
      begin
         initialize( 'Char' );
         return;
      end;
overriding member function get_type_string
      return varchar2 is
      begin
         return self.get_type_name( )
                || case when self.get_type_name( ) not like '%(%)%' then '(32767)' end;
      end;
   end;
/
