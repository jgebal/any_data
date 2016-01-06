drop type anydata_helper_bdouble force;
/

create or replace type anydata_helper_bdouble under anydata_helper_number (
  constructor function anydata_helper_bdouble return self as result
);
/

create or replace type body anydata_helper_bdouble as
   constructor function anydata_helper_bdouble return self as result is
      begin
         self.initialize( 'BDouble' );
         return;
      end;
   end;
/

