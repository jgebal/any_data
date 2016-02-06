create or replace type any_data_object under any_data_compound(
   constructor function any_data_object( p_type_name varchar2 ) return self as result
);
/

create or replace type body any_data_object as

   constructor function any_data_object( p_type_name varchar2 ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_object, p_type_name );
         self.data_values := any_data_tab();
         return;
      end;

end;
/
