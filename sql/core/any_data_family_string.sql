create or replace type any_data_family_string authid current_user under any_data(
   member function compare( p_other any_data, p_nulls_are_equal boolean := true ) return integer
) not final not instantiable;
/


create or replace type body any_data_family_string is

   member function compare( p_other any_data, p_nulls_are_equal boolean := true ) return integer is
      v_result integer := -1;
      begin
         if p_other is of ( any_data_family_string ) then
            v_result := any_data.compare( self, p_other, p_nulls_are_equal );
         end if;
         return v_result;
      end;

end;
/