create or replace type any_data_collection authid current_user under any_data_family_compound(
   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_type_code integer ) return self as result,
   constructor function any_data_collection( self in out nocopy any_data_collection, p_data_values any_data_tab ) return self as result,
   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer
);
/

create or replace type body any_data_collection as

   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_type_code integer ) return self as result is
      begin
         self.type_code := p_type_code;
         self.type_name := p_type_name;
         self.self_type_name := 'any_data_collection';
         self.data_values := any_data_tab();
         return;
      end;

   constructor function any_data_collection( self in out nocopy any_data_collection, p_data_values any_data_tab ) return self as result is
      begin
         self.type_code := dbms_types.typecode_table;
         self.self_type_name := 'any_data_collection';
         self.data_values := p_data_values;
         return;
      end;

   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer is
      v_result integer;
      function compare_elements( p_left any_data_tab, p_right any_data_tab ) return integer is
         v_result     integer;
         v_left_card  integer := cardinality( p_left );
         v_right_card integer := cardinality( p_right );
         begin
            if v_left_card = v_right_card
            then
               for i in 1 .. v_left_card loop
                  v_result := p_left(i).compare( p_right(i) );
                  exit when v_result != 0;
               end loop;
            elsif v_left_card > v_right_card then
               v_result := 1;
            elsif v_left_card < v_right_card then
               v_result := -1;
            end if;
            return v_result;
         end;
      begin
         return
            compare_elements(
               treat( p_left as any_data_collection).data_values,
               treat( p_right as any_data_collection).data_values
            );
      end compare_internal;

end;
/

