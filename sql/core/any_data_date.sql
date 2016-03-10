create or replace type any_data_date authid current_user under any_data_family_date(
   data_value date,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_date( self in out nocopy any_data_date, p_data date ) return self as result
);
/

create or replace type body any_data_date as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return
            string_array(
               q'[to_date( ']'
                  || to_char( data_value, 'yyyy-mm-dd hh24:mi:ss' )
                  || q'[', 'yyyy-mm-dd hh24:mi:ss' )]'
                  || p_separator
            );
      end;

   constructor function any_data_date( self in out nocopy any_data_date, p_data date ) return self as result is
      begin
         self.type_code := dbms_types.typecode_date;
         self.type_name := 'DATE';
         self.self_type_name := 'any_data_date';
         self.data_value := p_data;
         return;
      end;

end;
/
