drop type anydata_helper_collection force;
/

create or replace type anydata_helper_collection under anydata_helper_base (
   constructor function anydata_helper_collection return self as result,
   overriding member function get_sql_for_value_string return varchar2
);
/

create or replace type body anydata_helper_collection as
   constructor function anydata_helper_collection return self as result is
      begin
         self.initialize( 'Collection', '[' || chr( 10 ) || ''||dyn_sql_helper.to_sting_placeholder||'' || chr( 10 ) || ']'
         );
         return;
      end;
   overriding member function get_sql_for_value_string return varchar2 is
      begin
         return null;
      end;
   end;
/
