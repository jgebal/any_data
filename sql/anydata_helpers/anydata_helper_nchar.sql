drop type anydata_helper_nchar force;
/

create or replace type anydata_helper_nchar under anydata_helper_char (
  constructor function anydata_helper_nchar return self as result
);
/

create or replace type body anydata_helper_nchar as
   constructor function anydata_helper_nchar return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_NCHAR, 'NCHAR', 'Nchar');
         return;
      end;
   end;
/
