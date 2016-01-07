drop type anydata_timestamp_tz force;
/

create or replace type anydata_timestamp_tz under anydata_timestamp (
constructor function anydata_timestamp_tz return self as result
);
/

create or replace type body anydata_timestamp_tz as
   constructor function anydata_timestamp_tz return self as result is
      begin
         self.initialize( 'TimestampTZ' );
         return;
      end;
end;
/
