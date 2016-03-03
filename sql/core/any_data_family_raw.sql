create or replace type any_data_family_raw authid current_user under any_data(
   member function compare( p_other any_data, p_nulls_are_equal boolean := true ) return integer
) not final not instantiable;
/


create or replace type body any_data_family_raw is

   member function compare( p_other any_data, p_nulls_are_equal boolean := true ) return integer is
      v_result integer;
      v_sql    varchar2(32767);
      v_self   any_data_family_raw := self;
      begin
         v_sql := '
            declare
            begin
               :v_result :=
                  dbms_lob.compare(
                     treat( :v_self as '||v_self.get_self_type_name()||' ).data_value,
                     treat( :p_other as '||p_other.get_self_type_name()||' ).data_value );
            end;';

         if p_other is of ( any_data_family_raw ) then
            if p_nulls_are_equal then
               v_result := any_data.compare_nulls(self, p_other);
            end if;
            if v_result is null then
               execute immediate v_sql using out v_result, v_self, p_other;
            end if;
         else
            v_result := -1;
         end if;
         return v_result;
      end;

end;
/
