drop type anydata_helper_timestamp force;
/

create or replace type anydata_helper_timestamp under anydata_helper_base (
   member procedure initialize( p_function_suffix varchar2),
   constructor function anydata_helper_timestamp return self as result
) not final;
/

create or replace type body anydata_helper_timestamp as
   member procedure initialize( p_function_suffix varchar2) is
      begin
         self.initialize( p_function_suffix,
                          dyn_sql_helper.to_char( dyn_sql_helper.to_sting_placeholder, 'YYYY-MM-DD HH24:MI:SSxFF TZH:TZM' ) );
      end;
   constructor function anydata_helper_timestamp return self as result is
      begin
         initialize( 'Timestamp');
         return;
      end;
   end;
/
