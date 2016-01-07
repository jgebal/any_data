drop type anydata_number force;
/

create or replace type anydata_number under anydata_base (
   member procedure initialize( p_function_suffix varchar2),
   constructor function anydata_number return self as result
) not final;
/

create or replace type body anydata_number as
   member procedure initialize( p_function_suffix varchar2) is
      begin
         self.initialize( p_function_suffix,
                          anydata_helper.to_char( anydata_helper.to_sting_placeholder )
         );
      end;
   constructor function anydata_number return self as result is
      begin
         initialize( 'Number' );
         return;
      end;
   end;
/
