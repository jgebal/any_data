drop type anydata_helper_char force;
/

create or replace type anydata_helper_char under anydata_helper_base (
  member procedure initialize( p_typecode integer, p_type_name varchar2, p_function_suffix varchar2),
  overriding member function get_type_name return varchar2,
  constructor function anydata_helper_char return self as result
) not final;
/

create or replace type body anydata_helper_char as
   member procedure initialize( p_typecode integer, p_type_name varchar2, p_function_suffix varchar2) is
      begin
         self.data_prec_scale := 32767;
         self.initialize( p_typecode, p_type_name, p_function_suffix,
                          dyn_sql_helper.substr(
                             --need trim as anydata returns a char 32767 from any convert from CHAR datatype
                             dyn_sql_helper.trim(
                                dyn_sql_helper.to_sting_placeholder
                             ),
                             1,
                             dyn_sql_helper.max_return_data_length
                          )
         );
      end;
   constructor function anydata_helper_char return self as result is
      begin
         initialize( DBMS_TYPES.TYPECODE_CHAR, 'CHAR', 'Char' );
         return;
      end;
   overriding member function get_type_name
      return varchar2 is
      begin
         return type_name || '(32767)';
      end;
   end;
/
