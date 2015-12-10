drop type anydata_helper_number force;
/

create or replace type anydata_helper_number under anydata_helper_base (
   member procedure initialize( p_element_typecode integer, p_type_name varchar2, p_anydata_function_suffix varchar2),
   constructor function anydata_helper_number return self as result
) not final;
/

create or replace type body anydata_helper_number as
   member procedure initialize( p_element_typecode integer, p_type_name varchar2, p_anydata_function_suffix varchar2) is
      begin
         self.initialize( p_element_typecode, p_type_name, p_anydata_function_suffix, 'TO_CHAR( '||anytype_helper_const.anydata_getter_place||' )' );
      end;
   constructor function anydata_helper_number return self as result is
      begin
         initialize( DBMS_TYPES.TYPECODE_NUMBER, 'NUMBER', 'Number' );
         return;
      end;
   end;
/
