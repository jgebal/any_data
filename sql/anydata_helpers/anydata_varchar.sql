drop type anydata_varchar force;
/

create or replace type anydata_varchar under anydata_char (
  constructor function anydata_varchar return self as result
);
/

create or replace type body anydata_varchar as
   constructor function anydata_varchar return self as result is
      begin
         self.initialize( 'Varchar');
         return;
      end;
   end;
/
