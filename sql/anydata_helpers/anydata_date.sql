drop type anydata_date force;
/

create or replace type anydata_date under anydata_base (
constructor function anydata_date return self as result
);
/

create or replace type body anydata_date as
   constructor function anydata_date return self as result is
      begin
         self.initialize( 'Date',
                          anydata_helper.to_char( anydata_helper.to_sting_placeholder, 'YYYY-MM-DD HH24:MI:SS' )
         );
         return;
      end;
end;
/
