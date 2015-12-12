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
                          dyn_sql_helper.utl_raw_cast_to_varchar2(
                             dyn_sql_helper.dbms_lob_substr(
                                dyn_sql_helper.to_sting_placeholder,
                                dyn_sql_helper.max_return_data_length )
                          )
         );
         return;
      end;
   end;
/
