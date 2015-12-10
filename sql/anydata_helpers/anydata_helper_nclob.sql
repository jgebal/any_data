drop type anydata_helper_nclob force;
/

create or replace type anydata_helper_nclob under anydata_helper_base (
  constructor function anydata_helper_nclob return self as result
);
/

create or replace type body anydata_helper_nclob as
   constructor function anydata_helper_nclob return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_NCLOB, 'NCLOB', 'NClob',
                          '''"'' || TO_CHAR( dbms_lob.substr( '||anytype_helper_const.anydata_getter_place||', '||anytype_helper_const.max_data_length||' ) ) || ''"''' );
         return;
      end;
   end;
/
