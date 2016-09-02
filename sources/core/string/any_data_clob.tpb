create or replace type body any_data_clob as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( to_char( dbms_lob.substr( data_value, any_data_const.max_return_data_length ) ) , '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_clob( self in out nocopy any_data_clob, p_data clob ) return self as result is
      begin
         self.type_code := dbms_types.typecode_clob;
         self.type_name := 'CLOB';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         return;
      end;

   overriding member function get_value_hash return raw is
      begin
         return
            case when self.data_value is null then any_data_const.null_hash_value
            else dbms_crypto.hash( self.data_value, dbms_crypto.HASH_MD5 )
            end;
      end;

end;
/
