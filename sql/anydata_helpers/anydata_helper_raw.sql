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
                          dyn_sql_helper.to_char(
                             dyn_sql_helper.utl_raw_cast_to_varchar2(
                                dyn_sql_helper.to_sting_placeholder
                             )
                          )
         );
         return;
      end;
   end;
/
