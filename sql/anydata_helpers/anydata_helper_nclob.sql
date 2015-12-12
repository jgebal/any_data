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
                          dyn_sql_helper.to_char(
                             dyn_sql_helper.dbms_lob_substr(
                                dyn_sql_helper.to_sting_placeholder,
                                dyn_sql_helper.max_return_data_length
                             )
                          )
         );
         return;
      end;
   end;
/
