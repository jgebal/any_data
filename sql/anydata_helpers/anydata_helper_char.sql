drop type anydata_helper_char force;
/

create or replace type anydata_helper_char under anydata_helper_base (
  member procedure initialize( p_element_typecode integer, p_type_name varchar2, p_anydata_function_suffix varchar2),
  constructor function anydata_helper_char return self as result
) not final;
/

create or replace type body anydata_helper_char as
   member procedure initialize( p_element_typecode integer, p_type_name varchar2, p_anydata_function_suffix varchar2) is
      begin
         self.data_prec_scale := 32767;
         self.initialize( p_element_typecode, p_type_name, p_anydata_function_suffix,
                          '''"'' || REPLACE( REPLACE( substr( TRIM('||anytype_helper_const.anydata_getter_place||'), 1, '||anytype_helper_const.max_data_length||' ), ''\'', ''\\'' ), ''"'', ''\"'' ) || ''"''' );
      end;
   constructor function anydata_helper_char return self as result is
      begin
         initialize( DBMS_TYPES.TYPECODE_CHAR, 'CHAR', 'Char' );
         return;
      end;
   end;
/
