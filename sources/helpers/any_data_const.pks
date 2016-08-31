create or replace package any_data_const as

   get_version constant varchar2(30) := '&&VERSION';

   max_return_data_length constant integer := 2000;
   new_line               constant varchar2(2) := CHR( 10 );
   nulls_are_equal        constant boolean := true;
   null_hash_value        constant raw(1) := case when nulls_are_equal then hextoraw('00') end;
end;
/
