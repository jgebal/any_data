drop type any_data force;
/

create or replace type any_data as object(
   type_info any_type,
   not instantiable member function to_string return varchar2,
   not instantiable member procedure initialise( self in out nocopy any_data, p_data anydata ),
   member function get_type return any_type,
   member procedure set_type( self in out nocopy any_data, p_type any_type)
) not final not instantiable;
/

create or replace type body any_data as
   member function get_type return any_type is
      begin
         return type_info;
      end;
   member procedure set_type( self in out nocopy any_data, p_type any_type) is
      begin
         self.type_info := p_type;
      end;
end;
/

