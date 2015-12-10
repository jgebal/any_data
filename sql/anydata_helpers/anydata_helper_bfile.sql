drop type anydata_helper_bfile force;
/

create or replace type anydata_helper_bfile under anydata_helper_base (
  constructor function anydata_helper_bfile return self as result
);
/

create or replace type body anydata_helper_bfile as
   constructor function anydata_helper_bfile return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_BFILE, 'BFILE', 'Bfile',
                          '''"'' || TO_CHAR( utl_raw.cast_to_varchar2( dbms_lob.substr( '||anytype_helper_const.anydata_getter_place||', '||anytype_helper_const.max_data_length||' ) ) ) || ''"''' );
         return;
      end;
   end;
/
