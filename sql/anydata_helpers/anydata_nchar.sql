drop type anydata_nchar force;
/

create or replace type anydata_nchar under anydata_char (
  constructor function anydata_nchar return self as result
);
/

create or replace type body anydata_nchar as
   constructor function anydata_nchar return self as result is
      begin
         self.initialize( 'Nchar');
         return;
      end;
   end;
/
