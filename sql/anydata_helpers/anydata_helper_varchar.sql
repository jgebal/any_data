drop type anydata_helper_varchar force;
/

create or replace type anydata_helper_varchar under anydata_helper_char (
  constructor function anydata_helper_varchar return self as result
);
/

create or replace type body anydata_helper_varchar as
   constructor function anydata_helper_varchar return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_VARCHAR, 'VARCHAR', 'Varchar');
         return;
      end;
   end;
/
