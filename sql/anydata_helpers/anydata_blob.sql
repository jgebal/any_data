drop type anydata_blob force;
/

create or replace type anydata_blob under anydata_base (
constructor function anydata_blob return self as result
);
/

create or replace type body anydata_blob as
   constructor function anydata_blob return self as result is
      begin
         self.initialize( 'Blob',
                          anydata_helper.utl_raw_cast_to_varchar2(
                             anydata_helper.dbms_lob_substr(
                                anydata_helper.to_sting_placeholder,
                                anydata_helper.max_return_data_length )
                          )
         );
         return;
      end;
end;
/
