create or replace type anydata_object under anydata_compound (
constructor function anydata_object return self as result,
overriding member function get_elements_sql return varchar2,
overriding member function get_report return varchar2
);
/
