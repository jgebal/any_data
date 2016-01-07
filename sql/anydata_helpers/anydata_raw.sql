drop type anydata_raw force;
/

create or replace type anydata_raw under anydata_base (
constructor function anydata_raw return self as result
);
/

create or replace type body anydata_raw as
   constructor function anydata_raw return self as result is
      begin
         self.initialize( 'Raw',
                          anydata_helper.to_char(
                             anydata_helper.utl_raw_cast_to_varchar2(
                                anydata_helper.to_sting_placeholder
                             )
                          )
         );
         return;
      end;
end;
/
