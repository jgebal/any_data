create or replace type any_data as object(
   type_info any_type,
   not instantiable member function to_string return varchar2,
   member function get_type return any_type,
   member procedure add_element( self in out nocopy any_data, p_attribute any_data ),
   member function get_element( p_position integer ) return any_data,
   member function get_elements_count return integer
) not final not instantiable;
/

create or replace type body any_data as

   member function get_type return any_type is
      begin
         return type_info;
      end;

   member procedure add_element( self in out nocopy any_data, p_attribute any_data ) is
      begin
         raise_application_error(-2000, 'Feature not available for this type');
      end;

   member function get_element( p_position integer ) return any_data is
      begin
         return self;
      end;

   member function get_elements_count return integer is
      begin
         return 1;
      end;

end;
/

