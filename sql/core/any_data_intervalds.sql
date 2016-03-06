create or replace type any_data_intervalds authid current_user under any_data(
   data_value dsinterval_unconstrained,
   overriding member function get_self_family_name return varchar2,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data dsinterval_unconstrained ) return self as result
);
/

create or replace type body any_data_intervalds as

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_intervalds';
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( to_char( data_value ) || p_separator );
      end;

   /* Alternative implementation using 'unconstrained' data type workaround
     https://docs.oracle.com/cd/B19306_01/appdev.102/b14261/datatypes.htm
   */
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data dsinterval_unconstrained ) return self as result is
      begin
         self.type_code := dbms_types.typecode_interval_ds;
         self.type_name := 'INTERVAL DAY TO SECOND';
         self.self_type_name := 'any_data_intervalds';
         self.data_value := p_data;
         return;
      end;

end;
/
