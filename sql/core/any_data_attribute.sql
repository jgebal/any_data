create or replace type any_data_attribute authid current_user under any_data (
   name varchar2(400),
   data_value any_data,
   overriding member function get_self_family_name return varchar2,
   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_attribute( self in out nocopy any_data_attribute, p_name varchar2, p_data any_data ) return self as result
);
/

create or replace type body any_data_attribute is

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_attribute';
      end;

   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer is
      begin
         return
            case
               when treat(p_left as any_data_attribute).data_value is null
               then null
               when treat(p_left as any_data_attribute).name = treat(p_right as any_data_attribute).name
               then treat(p_left as any_data_attribute).data_value.compare( treat(p_right as any_data_attribute).data_value )
               when treat(p_left as any_data_attribute).name > treat(p_right as any_data_attribute).name
               then 1
               when treat(p_left as any_data_attribute).name < treat(p_right as any_data_attribute).name
               then -1
            end;
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result string_array;
      begin
         v_result := data_value.to_string_array( p_separator );
         v_result(1) := name || ' => ' || v_result(1);
         return v_result;
      end;

   constructor function any_data_attribute( self in out nocopy any_data_attribute, p_name varchar2, p_data any_data ) return self as result is
      begin
         self.self_type_name := 'any_data_attribute';
         self.name := p_name;
         self.data_value := p_data;
         return;
      end;

end;
/

