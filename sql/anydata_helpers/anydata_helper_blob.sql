drop type anydata_helper_blob force;
/

create or replace type anydata_helper_blob under anydata_helper_base (
  constructor function anydata_helper_blob return self as result
);
/

create or replace type body anydata_helper_blob as
   constructor function anydata_helper_blob return self as result is
      begin
         self.initialize( 'Blob',
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
