drop type any_data force;
/

create or replace type any_data as object(
   type_info any_type,
   member procedure add_element( self in out nocopy any_data, p_attribute any_data ),
   member function get_element( p_position integer ) return any_data,
   member function get_elements_count return integer,
   not instantiable member function to_string return varchar2,
   not instantiable member procedure initialise( self in out nocopy any_data, p_data anydata ),
   member function get_type return any_type,
   member procedure set_type( self in out nocopy any_data, p_type any_type)
) not final not instantiable;
/

create or replace type body any_data as
   member procedure add_element( self in out nocopy any_data, p_attribute any_data ) is
      begin
         null;
      end;
   member function get_element( p_position integer ) return any_data is
      begin
         return null;
      end;
   member function get_elements_count return integer is
      begin
         return 0;
      end;
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

