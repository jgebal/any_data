drop type anydata_helper_date force;
/

create or replace type anydata_helper_date under anydata_helper_base (
constructor function anydata_helper_date return self as result
);
/

create or replace type body anydata_helper_date as
   constructor function anydata_helper_date return self as result is
      begin
         self.initialize( dbms_types.typecode_date, 'DATE', 'Date',
                          dyn_sql_helper.to_char( dyn_sql_helper.to_sting_placeholder, 'YYYY-MM-DD HH24:MI:SS' )
         );
         return;
      end;
end;
/
