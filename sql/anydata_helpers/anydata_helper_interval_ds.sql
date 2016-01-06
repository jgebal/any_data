drop type anydata_helper_interval_ds force;
/

create or replace type anydata_helper_interval_ds under anydata_helper_base (
  constructor function anydata_helper_interval_ds return self as result
);
/

create or replace type body anydata_helper_interval_ds as
   constructor function anydata_helper_interval_ds return self as result is
      begin
         self.initialize( 'IntervalDS',
                          dyn_sql_helper.to_char( dyn_sql_helper.to_sting_placeholder )
         );
         return;
      end;
   end;
/

