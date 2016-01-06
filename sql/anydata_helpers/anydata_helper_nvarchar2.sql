drop type anydata_helper_nvarchar2 force;
/

create or replace type anydata_helper_nvarchar2 under anydata_helper_char (
  constructor function anydata_helper_nvarchar2 return self as result
);
/

create or replace type body anydata_helper_nvarchar2 as
   constructor function anydata_helper_nvarchar2 return self as result is
      begin
         self.initialize( 'Nvarchar2');
         return;
      end;
   end;
/

