drop type anydata_helper_raw force;
/

create or replace type anydata_helper_raw under anydata_helper_base (
  constructor function anydata_helper_raw return self as result
);
/

create or replace type body anydata_helper_raw as
   constructor function anydata_helper_raw return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_RAW, 'RAW', 'Raw',
                          '''"'' || TO_CHAR( utl_raw.cast_to_varchar2( '||anytype_helper_const.anydata_getter_place||', '||anytype_helper_const.max_data_length||' ) ) || ''"''' );
         return;
      end;
   end;
/
