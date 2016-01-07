drop type anydata_clob force;
/

create or replace type anydata_clob under anydata_base (
constructor function anydata_clob return self as result
);
/

create or replace type body anydata_clob as
   constructor function anydata_clob return self as result is
      begin
         self.initialize( 'Clob',
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
