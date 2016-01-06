drop type anydata_helper_varchar2 force;
/

create or replace type anydata_helper_varchar2 under anydata_helper_char (
  constructor function anydata_helper_varchar2 return self as result
);
/

create or replace type body anydata_helper_varchar2 as
   constructor function anydata_helper_varchar2 return self as result is
      begin
         self.initialize( 'Varchar2' );
         return;
      end;
   end;
/
