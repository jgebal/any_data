drop type anydata_bfloat force;
/

create or replace type anydata_bfloat under anydata_number (
  constructor function anydata_bfloat return self as result
);
/

create or replace type body anydata_bfloat as
   constructor function anydata_bfloat return self as result is
      begin
         self.initialize( 'BFloat' );
         return;
      end;
   end;
/

