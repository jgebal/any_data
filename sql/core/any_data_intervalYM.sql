create or replace type any_data_intervalym under any_data(
   data_value yminterval_unconstrained,
   overriding member function to_string return varchar2,
   constructor function any_data_intervalym( self in out nocopy any_data_intervalym, p_data yminterval_unconstrained ) return self as result
);
/

create or replace type body any_data_intervalym as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value );
      end;

   /* Alternative implementation using 'unsconstrained' data type workaround
     https://docs.oracle.com/cd/B19306_01/appdev.102/b14261/datatypes.htm
   */
   constructor function any_data_intervalym( self in out nocopy any_data_intervalym, p_data yminterval_unconstrained ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'INTERVAL YEAR TO MONTH' );
         self.data_value := p_data;
         return;
      end;

end;
/
