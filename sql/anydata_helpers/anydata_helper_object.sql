drop type anydata_helper_object force;
/

create or replace type anydata_helper_object under anydata_helper_base (
   constructor function anydata_helper_object return self as result,
   overriding member function get_value_as_string return varchar2
);
/

create or replace type body anydata_helper_object as
   constructor function anydata_helper_object return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_OBJECT, NULL, 'Object',
                          '{' || chr( 10 ) || ''||dyn_sql_helper.to_sting_placeholder||'' || chr( 10 ) ||'}'
         );
         return;
      end;
   overriding member function get_value_as_string return varchar2 is
      begin
         return null;
      end;
   end;
/
