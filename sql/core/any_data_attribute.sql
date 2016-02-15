create or replace type any_data_attribute under any_data (
   name varchar2(400),
   data any_data,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   overriding member function get_type return any_type
);
/

create or replace type body any_data_attribute is

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result string_array;
      begin
         v_result := data.to_string_array( p_separator );
         v_result(1) := name || ' => ' || v_result(1);
         return v_result;
      end;

   overriding member function get_type return any_type is
      begin
         return data.type_info;
      end;

end;
/

