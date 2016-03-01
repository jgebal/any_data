create or replace type any_data_family_raw authid current_user under any_data(
   member function compare( p_other any_data, p_nulls_are_equal varchar2 := 'N' ) return integer
) not final not instantiable;
/


create or replace type body any_data_family_raw is

   member function compare( p_other any_data, p_nulls_are_equal varchar2 := 'N' ) return integer is
      v_result integer := -1;
      v_sql    varchar2(32767);
      v_self   any_data_family_raw := self;
      begin
         if p_other is of ( any_data_family_raw ) then
            v_sql := '
               declare
               begin
                  :v_result :=
                     case
                        '||case when upper(p_nulls_are_equal) = 'Y' then
                       'when treat( :v_self as '||v_self.get_self_type_name()||' ).data_value is null
                        then
                           case
                              when treat( :p_other as '||p_other.get_self_type_name()||' ).data_value is null
                              then 0
                              else -1
                           end
                        when treat( :p_other as '||p_other.get_self_type_name()||' ).data_value is null
                        then 1'
                        end||'
                        when 1 = 1
                        then dbms_lob.compare(
                               treat( :v_self as '||v_self.get_self_type_name()||' ).data_value,
                               treat( :p_other as '||p_other.get_self_type_name()||' ).data_value )
                     end;
               end;';
--         dbms_output.put_line(v_sql);
            execute immediate v_sql using out v_result, v_self, p_other;
         end if;
         return v_result;
      end;

end;
/
