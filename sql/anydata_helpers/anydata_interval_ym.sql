drop type anydata_interval_ym force;
/

create or replace type anydata_interval_ym under anydata_base (
  constructor function anydata_interval_ym return self as result
);
/

create or replace type body anydata_interval_ym as
   constructor function anydata_interval_ym return self as result is
      begin
         self.initialize( 'IntervalYM',
                          anydata_helper.to_char( anydata_helper.to_sting_placeholder )
         );
         return;
      end;
   end;
/
