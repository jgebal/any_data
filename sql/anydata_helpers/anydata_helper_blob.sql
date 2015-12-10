drop type anydata_helper_blob force;
/

create or replace type anydata_helper_blob under anydata_helper_base (
  constructor function anydata_helper_blob return self as result
);
/

create or replace type body anydata_helper_blob as
   constructor function anydata_helper_blob return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_BLOB, 'BLOB', 'Blob',
                          '''"'' || TO_CHAR( utl_raw.cast_to_varchar2( dbms_lob.substr( '||anytype_helper_const.anydata_getter_place||', '||anytype_helper_const.max_data_length||' ) ) ) || ''"''' );
         return;
      end;
   end;
/
