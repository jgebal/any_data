create or replace type body any_data_family_compound as

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_family_compound';
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result         string_array;
      v_values_count   binary_integer := get_elements_count();
      v_elements       string_array;
      v_separator      varchar2(1) := ',';
      begin
         v_result := string_array( self.type_name || '(' );

         for i in 1 .. v_values_count loop
            if i = v_values_count then v_separator := null; end if;
            v_elements := any_data_formatter.indent_lines( data_values( i ).to_string_array( v_separator ) );
            for j in 1 .. cardinality( v_elements ) loop
               v_result.extend();
               v_result( v_result.last ) := v_elements( j );
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
         return cardinality( data_values );
      end;

   overriding member function compare_internal( p_other any_data ) return integer is
      v_result integer;
      function compare_elements( p_data_values any_data_tab ) return integer is
         v_result integer;
         v_card   integer := get_elements_count();
         begin
            for i in 1 .. v_card loop
               v_result :=
               case
               when any_data_const.nulls_are_equal and data_values(i) is null and p_data_values(i) is null
                  then 0
               else data_values(i).compare( p_data_values(i) )
               end;
               exit when nvl( v_result, -1 ) != 0;
            end loop;
            return v_result;
         end;
      function do_compare( p_other any_data_family_compound ) return integer is
         begin
            return
            case
            when self.get_elements_count()= p_other.get_elements_count()
               then compare_elements( p_other.data_values )
            when self.get_elements_count() > p_other.get_elements_count()
               then 1
            when self.get_elements_count() < p_other.get_elements_count()
               then -1
            when any_data_const.nulls_are_equal
                 and self.data_values is null and p_other.data_values is null
               then 0
            end;
         end;
      begin
         return do_compare( treat( p_other as any_data_family_compound ) );
      end compare_internal;

end;
/
