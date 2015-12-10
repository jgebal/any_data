drop type anydata_helper_clob force;
/

create or replace type anydata_helper_clob under anydata_helper_base (
  constructor function anydata_helper_clob return self as result
);
/

create or replace type body anydata_helper_clob as
   constructor function anydata_helper_clob return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_CLOB, 'CLOB', 'Clob',
                          '''"'' || TO_CHAR( dbms_lob.substr( '||anytype_helper_const.anydata_getter_place||', '||anytype_helper_const.max_data_length||' ) ) || ''"''' );
         return;
      end;
   end;
/
