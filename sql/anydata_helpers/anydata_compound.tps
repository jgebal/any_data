create or replace type anydata_compound under anydata_base (
member procedure initialize( p_function_suffix varchar2 ),
overriding final member function get_value_as_string return varchar2,
not instantiable member function get_elements_sql return varchar2,
member function get_sql_for_attribute( p_position integer := null ) return varchar2
) not final not instantiable;
/
