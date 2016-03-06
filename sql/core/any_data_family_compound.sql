create or replace type any_data_family_compound authid current_user under any_data(
   data_values     any_data_tab,
   overriding member function get_self_family_name return varchar2,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   overriding member procedure add_element( self in out nocopy any_data_family_compound, p_attribute any_data ),
   overriding member function get_element( p_position integer ) return any_data,
   overriding member function get_elements_count return integer
) not final not instantiable;
/

create or replace type body any_data_family_compound as

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_family_compound';
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result         string_array;
      v_values_count   binary_integer := get_elements_count();
      v_elements       string_array;
      v_elements_count binary_integer;
      v_result_idx     binary_integer := 2;
      v_separator      varchar2(1) := ',';
      begin
         v_result := string_array( self.type_name || '(' );

         for i in 1 .. v_values_count loop
            if i = v_values_count then v_separator := null; end if;
            v_elements := any_data_formatter.indent_lines( data_values( i ).to_string_array( v_separator ) );
            v_elements_count := coalesce( cardinality( v_elements ), 0 );
            v_result.extend( v_elements_count );
            for j in 1 .. v_elements_count loop
               v_result( v_result_idx ) := v_elements( j );
               v_result_idx := v_result_idx + 1;
            end loop;
         end loop;

         v_result.extend;
         v_result( v_result.last ) := ')'||p_separator;
         return v_result;
      end;

   overriding member procedure add_element( self in out nocopy any_data_family_compound, p_attribute any_data ) is
      begin
         data_values.extend;
         data_values( data_values.last ) := p_attribute;
      end;

   overriding member function get_element( p_position integer ) return any_data is
      begin
         return data_values( p_position );
      end;

   overriding member function get_elements_count return integer is
      begin
         return coalesce( cardinality( data_values ), 0 );
      end;

end;
/

