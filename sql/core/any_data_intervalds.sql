create or replace type any_data_intervalds under any_data(
   data_value interval day(9) to second(9),
   overriding member function to_string return varchar2,
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data interval day to second ) return self as result
);
/

create or replace type body any_data_intervalds as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value );
      end;

   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data interval day to second ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'INTERVAL DAY TO SECOND' );
         self.data_value := p_data;
         return;
      end;

end;
/
