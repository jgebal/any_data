create or replace type any_data_intervalds under any_data(
   data_value dsinterval_unconstrained,
   overriding member function to_string return varchar2,
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data dsinterval_unconstrained ) return self as result
);
/

create or replace type body any_data_intervalds as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value );
      end;

   /* Alternative implementation using 'unsconstrained' data type workaround
     https://docs.oracle.com/cd/B19306_01/appdev.102/b14261/datatypes.htm
   */
   constructor function any_data_intervalds( self in out nocopy any_data_intervalds, p_data dsinterval_unconstrained ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'INTERVAL DAY TO SECOND' );
         self.data_value := p_data;
         return;
      end;

end;
/
