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
      c_cardinlaity constant integer := coalesce(cardinality(p_data_values),0);
      l_name_hashes raw(1600);
      l_type_hashes raw(1600);
      l_value_hashes raw(1600);
      i integer := 1;
      x integer;
      begin
         self.data_values := p_data_values;
--         for i in 1 .. c_cardinlaity loop
--            self.name_hash := dbms_crypto.hash( self.name_hash||data_values(i).name_hash, dbms_crypto.HASH_MD5 );
--            self.type_hash := dbms_crypto.hash( self.type_hash||data_values(i).type_hash, dbms_crypto.HASH_MD5 );
--            self.value_hash := dbms_crypto.hash( self.value_hash||data_values(i).value_hash, dbms_crypto.HASH_MD5 );
--         end loop;
         loop
            exit when i >= c_cardinlaity;
            x := least(i+99,c_cardinlaity);
            for j in i .. x loop
               l_name_hashes := l_name_hashes||data_values(j).name_hash;
               l_type_hashes := l_name_hashes||data_values(j).type_hash;
               l_value_hashes := l_name_hashes||data_values(j).value_hash;
            end loop;
            self.name_hash := dbms_crypto.hash( self.name_hash||l_name_hashes, dbms_crypto.HASH_MD5 );
            self.type_hash := dbms_crypto.hash( self.type_hash||l_name_hashes, dbms_crypto.HASH_MD5 );
            self.value_hash := dbms_crypto.hash( self.value_hash||l_name_hashes, dbms_crypto.HASH_MD5 );
            l_name_hashes := null;
            l_type_hashes := null;
            l_value_hashes := null;
            i := i + 100;
         end loop;
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
