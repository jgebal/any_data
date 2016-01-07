drop type anydata_timestamp force;
/

create or replace type anydata_timestamp under anydata_base (
member procedure initialize( p_function_suffix varchar2 ),
constructor function anydata_timestamp return self as result
) not final;
/

create or replace type body anydata_timestamp as
member procedure initialize( p_function_suffix varchar2 ) is
      begin
         self.initialize( p_function_suffix,
                          anydata_helper.to_char( anydata_helper.to_sting_placeholder,
                                                  'YYYY-MM-DD HH24:MI:SSxFF TZH:TZM' ) );
      end;
   constructor function anydata_timestamp return self as result is
      begin
         initialize( 'Timestamp' );
         return;
      end;
end;
/
