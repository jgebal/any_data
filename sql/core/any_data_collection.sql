create or replace type any_data_collection authid current_user under any_data_compound(
   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_type_code integer ) return self as result
);
/

create or replace type body any_data_collection as

   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_type_code integer ) return self as result is
      begin
         self.type_code := p_type_code;
         self.type_name := p_type_name;
         self.data_values := any_data_tab();
         return;
      end;

end;
/

