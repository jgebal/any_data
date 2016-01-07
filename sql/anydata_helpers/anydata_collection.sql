drop type anydata_collection force;
/

create or replace type anydata_collection under anydata_base (
   constructor function anydata_collection return self as result,
   overriding member function get_sql_for_value_string return varchar2
);
/

create or replace type body anydata_collection as
   constructor function anydata_collection return self as result is
      begin
         self.initialize( 'Collection', '[' || anydata_helper.new_line || ''||anydata_helper.to_sting_placeholder||'' || anydata_helper.new_line || ']'
         );
         return;
      end;
   overriding member function get_sql_for_value_string return varchar2 is
      begin
         return null;
      end;
   end;
/
