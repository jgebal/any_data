create or replace type any_data_date under any_data(
   data_value date,
   overriding member function to_string return varchar2,
   constructor function any_data_date( self in out nocopy any_data_date, p_data date ) return self as result
);
/

create or replace type body any_data_date as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value, 'yyyy-mm-dd hh24:mi:ss' );
      end;

   constructor function any_data_date( self in out nocopy any_data_date, p_data date ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'DATE' );
         self.data_value := p_data;
         return;
      end;

end;
/
