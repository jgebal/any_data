drop type anydata_helper_interval_ds force;
/

create or replace type anydata_helper_interval_ds under anydata_helper_base (
  constructor function anydata_helper_interval_ds return self as result
);
/

create or replace type body anydata_helper_interval_ds as
   constructor function anydata_helper_interval_ds return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_INTERVAL_DS, 'INTERVAL DAY TO SECOND', 'IntervalDS',
                          'TO_CHAR( '||anytype_helper_const.anydata_getter_place||' )' );
         return;
      end;
   end;
/

