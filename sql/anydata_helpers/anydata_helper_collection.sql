drop type anydata_helper_collection force;
/

create or replace type anydata_helper_collection under anydata_helper_base (
   constructor function anydata_helper_collection return self as result,
   overriding member function get_report( p_data anydata ) return varchar2
);
/

create or replace type body anydata_helper_collection as
   constructor function anydata_helper_collection return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_VARRAY, NULL, 'Collection', '[' || chr( 10 ) || ''||anytype_helper_const.anydata_getter_place||'' || chr( 10 ) || ']' );
         return;
      end;
   overriding member function get_report( p_data anydata ) return varchar2 is
      begin
         return null;
      end;
   end;
/
