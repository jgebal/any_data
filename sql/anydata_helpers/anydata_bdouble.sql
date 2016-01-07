drop type anydata_bdouble force;
/

create or replace type anydata_bdouble under anydata_number (
  constructor function anydata_bdouble return self as result
);
/

create or replace type body anydata_bdouble as
   constructor function anydata_bdouble return self as result is
      begin
         self.initialize( 'BDouble' );
         return;
      end;
   end;
/

