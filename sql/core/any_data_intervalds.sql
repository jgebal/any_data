create or replace type any_data_intervalds under any_data(
   data_value interval day(9) to second(9),
   overriding member function to_string return varchar2,
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data varchar2 ) return self as result
);
/

create or replace type body any_data_intervalds as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value );
      end;

/*
A hack needs to be used in PL/SQL as Oracle doesn't allow intervals with precision bigger than default to be passed as parameters
Example of not working code:
   declare
      i interval day(9) to second(9);
      procedure p_tst(p interval day to second) is
         begin
            null;
         end;
      function f_tst return interval day to second is
         i interval day(9) to second(9);
         begin
            i := INTERVAL '123456789 23:59:59.123456789' DAY TO SECOND;
            return i;
         end;
   begin
      i := INTERVAL '123456789 23:59:59.123456789' DAY TO SECOND;
      p_tst(i);
      i := f_tst();
   end;
*/
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data varchar2 ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'INTERVAL DAY TO SECOND' );
         self.data_value := p_data;
         return;
      end;

end;
/
