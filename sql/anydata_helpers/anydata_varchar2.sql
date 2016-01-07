drop type anydata_varchar2 force;
/

create or replace type anydata_varchar2 under anydata_char (
constructor function anydata_varchar2 return self as result
);
/

create or replace type body anydata_varchar2 as
   constructor function anydata_varchar2 return self as result is
      begin
         self.initialize( 'Varchar2' );
         return;
      end;
end;
/
