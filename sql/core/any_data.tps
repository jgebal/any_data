create or replace type any_data authid current_user as object(
   type_code number(38, 0),
   type_name varchar2(100),
   final member function to_string return varchar2,
   not instantiable member function to_string_array( p_separator varchar2 := null ) return string_array,
   member procedure add_element( self in out nocopy any_data, p_attribute any_data ),
   member function get_element( p_position integer ) return any_data,
   member function get_elements_count return integer
) not final not instantiable;
/

create or replace type body any_data as

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

   final member function to_string return varchar2 is
      v_array string_array;
      v_result varchar2(32767);
      v_array_size binary_integer;
      begin
         v_array := to_string_array( );
         v_array_size := cardinality( v_array );
         for i in 1 .. v_array_size  loop
            v_result := v_result || v_array(i) || any_data_formatter.new_line;
         end loop;
         return rtrim( v_result, any_data_formatter.new_line );
      end;
end;
/

