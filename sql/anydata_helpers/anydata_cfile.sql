drop type anydata_cfile force;
/

create or replace type anydata_cfile under anydata_base (
constructor function anydata_cfile return self as result
);
/

create or replace type body anydata_cfile as
   constructor function anydata_cfile return self as result is
      begin
         self.initialize( 'Cfile',
                          anydata_helper.dbms_lob_substr(
                             anydata_helper.to_sting_placeholder,
                             anydata_helper.max_return_data_length )
         );

         return;
      end;
end;
/
