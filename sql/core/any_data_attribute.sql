create or replace type any_data_attribute authid current_user under any_data (
   name varchar2(400),
   data_value any_data,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_attribute( self in out nocopy any_data_attribute, p_data any_data ) return self as result
);
/

create or replace type body any_data_attribute is

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result string_array;
      begin
         v_result := data_value.to_string_array( p_separator );
         v_result(1) := name || ' => ' || v_result(1);
         return v_result;
      end;

   constructor function any_data_attribute( self in out nocopy any_data_attribute, p_data any_data ) return self as result is
      begin
         self.self_type_name := 'any_data_attribute';
         self.data_value := p_data;
      end;

end;
/

