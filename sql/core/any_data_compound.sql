create or replace type any_data_compound under any_data(
   data_values     any_data_tab,
   overriding member function to_string return varchar2,
   overriding member procedure add_element( self in out nocopy any_data_compound, p_attribute any_data ),
   overriding member function get_element( p_position integer ) return any_data,
   overriding member function get_elements_count return integer
) not final not instantiable;
/

create or replace type body any_data_compound as

   overriding member function to_string return varchar2 is
      v_result varchar2(32767);
      values_count  integer := get_elements_count();
      begin
         v_result := self.get_type().type_name || '(' || any_data_formatter.new_line;
         for i in 1 .. values_count loop
            v_result := v_result ||
                        any_data_formatter.indent_lines(
                           data_values(i).to_string() || case when i < values_count then ',' end
                        ) || any_data_formatter.new_line;
         end loop;

         return v_result || ')';
      end;

   overriding member procedure add_element( self in out nocopy any_data_compound, p_attribute any_data ) is
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

