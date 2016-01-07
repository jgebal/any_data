drop type anydata_nclob force;
/

create or replace type anydata_nclob under anydata_base (
  constructor function anydata_nclob return self as result
);
/

create or replace type body anydata_nclob as
   constructor function anydata_nclob return self as result is
      begin
         self.initialize( 'NClob',
                          anydata_helper.to_char(
                             anydata_helper.dbms_lob_substr(
                                anydata_helper.to_sting_placeholder,
                                anydata_helper.max_return_data_length
                             )
                          )
         );
         return;
      end;
   end;
/
