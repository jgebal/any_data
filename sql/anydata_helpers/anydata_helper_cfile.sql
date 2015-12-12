drop type anydata_helper_cfile force;
/

create or replace type anydata_helper_cfile under anydata_helper_base (
constructor function anydata_helper_cfile return self as result
);
/

create or replace type body anydata_helper_cfile as
   constructor function anydata_helper_cfile return self as result is
      begin
         self.initialize( dbms_types.typecode_bfile, 'BFILE', 'Bfile',
                          dyn_sql_helper.dbms_lob_substr(
                             dyn_sql_helper.to_sting_placeholder,
                             dyn_sql_helper.max_return_data_length )
         );

         return;
      end;
end;
/
