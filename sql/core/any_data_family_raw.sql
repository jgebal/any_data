create or replace type any_data_family_raw authid current_user under any_data(
   overriding member function get_self_family_name return varchar2,
   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer
) not final not instantiable;
/


create or replace type body any_data_family_raw is

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_family_raw';
      end;

   overriding member function compare_internal( p_left any_data, p_right any_data ) return integer is
      v_result integer;
      c_sql  constant varchar2(32767) := '
            declare
            begin
               :v_result :=
                  dbms_lob.compare(
                     treat( :v_self as '||p_left.get_self_type_name()||' ).data_value,
                     treat( :p_other as '||p_right.get_self_type_name()||' ).data_value );
            end;';
      begin
         execute immediate c_sql using out v_result, p_left, p_right;
         return v_result;
      end;

end;
/
