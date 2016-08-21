create or replace type any_data_family_raw authid current_user under any_data(
   overriding member function get_self_family_name return varchar2,
   overriding member function compare_internal( p_other any_data ) return integer
) not final not instantiable;
/
