create or replace type any_data_collection authid current_user under any_data_family_compound(
   constructor function any_data_collection( self in out nocopy any_data_collection, p_type_name varchar2, p_data_values any_data_tab ) return self as result,
   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer
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

   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer is
      v_result integer;
      function compare_elements( p_left any_data_tab, p_right any_data_tab ) return integer is
         v_result integer;
         v_card   integer := cardinality(p_left);
         begin
            for i in 1 .. v_card loop
               v_result :=
                  case
                     when any_data_const.nulls_are_equal
                      and p_left(i) is null
                      and p_right(i) is null
                     then 0
                     else p_left(i).compare( p_right(i) )
                  end;
               exit when nvl( v_result, -1 ) != 0;
            end loop;
            return v_result;
         end;
      begin
         return
            case
               when any_data_const.nulls_are_equal
                and treat( p_left as any_data_collection).data_values is null
                and treat( p_right as any_data_collection).data_values is null
               then 0
               when treat( p_left as any_data_collection).get_elements_count()
                    = treat( p_right as any_data_collection).get_elements_count()
               then
                  compare_elements(
                     treat( p_left as any_data_collection).data_values,
                     treat( p_right as any_data_collection).data_values
                  )
               when treat( p_left as any_data_collection).get_elements_count()
                 > treat( p_right as any_data_collection).get_elements_count()
               then 1
               when treat( p_left as any_data_collection).get_elements_count()
                 < treat( p_right as any_data_collection).get_elements_count()
               then -1
            end;
      end compare_internal;

end;
/

