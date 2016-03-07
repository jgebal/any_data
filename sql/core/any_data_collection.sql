create or replace type any_data_collection authid current_user under any_data_family_compound(
   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_data_values any_data_tab ) return self as result,
   overriding member function compare_internal( p_other any_data ) return integer
);
/

create or replace type body any_data_collection as

   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_data_values any_data_tab ) return self as result is
      begin
         self.type_code := dbms_types.typecode_table;
         self.type_name := p_type_name;
         self.self_type_name := 'any_data_collection';
         self.data_values := p_data_values;
         return;
      end;

   overriding member function compare_internal( p_other any_data ) return integer is
      v_result integer;
      function do_compare( p_other any_data_family_compound ) return integer is
         begin
            return
               case
                  when self.get_elements_count()= p_other.get_elements_count()
                  then self.compare_elements( p_other.data_values )
                  when self.get_elements_count() > p_other.get_elements_count()
                  then 1
                  when self.get_elements_count() < p_other.get_elements_count()
                  then -1
                  when any_data_const.nulls_are_equal
                    and self.data_values is null and p_other.data_values is null
                  then 0
               end;
         end;
      begin
         return do_compare( treat( p_other as any_data_family_compound ) );
      end compare_internal;

end;
/

