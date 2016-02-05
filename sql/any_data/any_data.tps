drop type any_data force;
/

create or replace type any_data as object(
   type_info any_type,
   not instantiable member function to_string return varchar2,
not instantiable member procedure initialise( self in out nocopy any_data, p_data anydata )
) not final not instantiable;
/

