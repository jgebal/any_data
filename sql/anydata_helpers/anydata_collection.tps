create or replace type anydata_collection under anydata_compound (
constructor function anydata_collection return self as result,
overriding member function get_sql_for_value_string return varchar2,
overriding member function get_value_as_string return varchar2,
overriding member function get_report return varchar2
);
/
