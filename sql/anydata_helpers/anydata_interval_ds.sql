drop type anydata_interval_ds force;
/

create or replace type anydata_interval_ds under anydata_base (
  constructor function anydata_interval_ds return self as result
);
/

create or replace type body anydata_interval_ds as
   constructor function anydata_interval_ds return self as result is
      begin
         self.initialize( 'IntervalDS',
                          anydata_helper.to_char( anydata_helper.to_sting_placeholder )
         );
         return;
      end;
   end;
/

