create or replace type any_data_bdouble under any_data(
   data_value binary_double,
   overriding member function to_string return varchar2,
   constructor function any_data_bdouble( self in out nocopy any_data_bdouble, p_data binary_double ) return self as result
);
/

create or replace type body any_data_bdouble as

   overriding member function to_string return varchar2 is
      begin
         return to_char( data_value );
      end;

   constructor function any_data_bdouble( self in out nocopy any_data_bdouble, p_data binary_double ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'BINARY_DOUBLE' );
         self.data_value := p_data;
         return;
      end;

end;
/
