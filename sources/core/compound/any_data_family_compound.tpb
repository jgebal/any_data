create or replace type body any_data_family_compound as

   overriding member function get_self_family_name return varchar2 is
      begin
         return $$PLSQL_UNIT;
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result         string_array;
      v_values_count   binary_integer := get_elements_count();
      v_elements       string_array;
      v_separator      varchar2(1) := ',';
      begin
         v_result := string_array( self.type_name || '(' );

         for i in 1 .. v_values_count loop
            if i = v_values_count then v_separator := null; end if;
            v_elements := any_data_formatter.indent_lines( data_values( i ).to_string_array( v_separator ) );
            for j in 1 .. cardinality( v_elements ) loop
               v_result.extend();
               v_result( v_result.last ) := v_elements( j );
            end loop;
         end loop;

         v_result.extend;
         v_result( v_result.last ) := ')'||p_separator;
         return v_result;
      end;

   overriding member function get_elements_count return integer is
      begin
         return cardinality( data_values );
      end;

   member procedure set_data_values(self in out nocopy any_data_family_compound, p_data_values any_data_tab) is
      c_cardinality constant integer := coalesce(cardinality(p_data_values),0);
      l_name_hashes blob;
      l_type_hashes blob;
      l_value_hashes blob;
      begin
         self.data_values := p_data_values;
         if c_cardinality > 0 then
            dbms_lob.createtemporary ( l_name_hashes,  true, dbms_lob.call);
            dbms_lob.createtemporary ( l_type_hashes,  true, dbms_lob.call);
            dbms_lob.createtemporary ( l_value_hashes, true, dbms_lob.call);
            for i in 1 ..  c_cardinality loop
               if data_values(i) is not null and data_values(i).name_hash is not null then dbms_lob.writeappend( l_name_hashes,  16,  data_values(i).name_hash ); end if;
               if data_values(i) is not null and data_values(i).type_hash is not null then dbms_lob.writeappend( l_type_hashes,  16,  data_values(i).type_hash ); end if;
               if data_values(i) is not null and data_values(i).value_hash is not null then dbms_lob.writeappend( l_value_hashes, 16, data_values(i).value_hash ); end if;
            end loop;
            self.name_hash := dbms_crypto.hash( l_name_hashes, dbms_crypto.HASH_MD5 );
            self.type_hash := dbms_crypto.hash( l_type_hashes, dbms_crypto.HASH_MD5 );
            self.value_hash := dbms_crypto.hash( l_value_hashes, dbms_crypto.HASH_MD5 );
         else
            self.name_hash :=  any_data_const.null_hash_value;
            self.type_hash :=  any_data_const.null_hash_value;
            self.value_hash := any_data_const.null_hash_value;
         end if;
      end;

   overriding member function compare_internal( p_other any_data ) return integer is
      v_result integer;
      function compare_elements( p_data_values any_data_tab ) return integer is
         v_result integer;
         v_card   integer := get_elements_count();
         begin
            for i in 1 .. v_card loop
               v_result :=
               case
               when any_data_const.nulls_are_equal and data_values(i) is null and p_data_values(i) is null
                  then 0
               else data_values(i).compare( p_data_values(i) )
               end;
               exit when nvl( v_result, -1 ) != 0;
            end loop;
            return v_result;
         end;
      function do_compare( p_other any_data_family_compound ) return integer is
         begin
            return
            case
            when self.get_elements_count()= p_other.get_elements_count()
               then compare_elements( p_other.data_values )
            when self.get_elements_count() > p_other.get_elements_count()
               then 1
            when self.get_elements_count() < p_other.get_elements_count()
               then -1
            when any_data_const.nulls_are_equal
                 and self.data_values is null and p_other.data_values is null
               then 0
            end;
         end;
      begin
         return do_compare( treat( p_other as any_data_family_compound ) );
      end compare_internal;

end;
/
