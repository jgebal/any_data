drop type anydata_helper_timestamp_ltz force;
/

create or replace type anydata_helper_timestamp_ltz under anydata_helper_timestamp (
   constructor function anydata_helper_timestamp_ltz return self as result
);
/

create or replace type body anydata_helper_timestamp_ltz as
   constructor function anydata_helper_timestamp_ltz return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_TIMESTAMP_LTZ, 'TIMESTAMP WITH LOCAL TIME ZONE', 'TimestampLTZ');
         return;
      end;
   end;
/
