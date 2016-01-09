create or replace type anydata_char under anydata_base (
constructor function anydata_char( p_function_suffix varchar2 ) return self as result,
overriding member function get_type_def return varchar2,
overriding member function get_value_as_string return varchar2
) not final;
/
