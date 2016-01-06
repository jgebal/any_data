drop type anydata_helper_bfloat force;
/

create or replace type anydata_helper_bfloat under anydata_helper_number (
  constructor function anydata_helper_bfloat return self as result
);
/

create or replace type body anydata_helper_bfloat as
   constructor function anydata_helper_bfloat return self as result is
      begin
         self.initialize( 'BFloat' );
         return;
      end;
   end;
/

