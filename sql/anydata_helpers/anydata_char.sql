drop type anydata_char force;
/

create or replace type anydata_char under anydata_base (
   member procedure initialize( p_function_suffix varchar2),
   overriding member function get_type_string return varchar2,
   constructor function anydata_char return self as result
) not final;
/

create or replace type body anydata_char as
   member procedure initialize( p_function_suffix varchar2 ) is
      begin
         self.initialize(
            p_function_suffix,
            '''"''||'
            || anydata_helper.substr(
                  --need trim as anydata returns a char 32767 from any convert from CHAR datatype
                  anydata_helper.trim(
                     anydata_helper.to_sting_placeholder
                  ),
                  1,
                  anydata_helper.max_return_data_length - 2
               )
            || '||''"'''
         );
      end;
   constructor function anydata_char return self as result is
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
