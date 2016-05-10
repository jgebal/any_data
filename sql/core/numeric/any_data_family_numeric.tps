create or replace type any_data_family_numeric authid current_user under any_data(
   overriding member function get_self_family_name return varchar2
) not final not instantiable;
/
