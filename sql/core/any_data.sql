create or replace type any_data authid current_user as object(
   type_code      number(38, 0),
   type_name      varchar2(100),
   self_type_name varchar2(100),
   final member function to_string return varchar2,
   not instantiable member function to_string_array( p_separator varchar2 := null ) return string_array,
   not instantiable member function get_self_family_name return varchar2,
   member function get_self_type_name return varchar2,
   member procedure add_element( self in out nocopy any_data, p_attribute any_data ),
   member function get_element( p_position integer ) return any_data,
   member function compare_internal( p_left any_data, p_right any_data ) return integer,
   order member function compare( p_other any_data ) return integer,
   member function get_elements_count return integer
) not final not instantiable;
/

create or replace type body any_data as

   final member function to_string return varchar2 is
      v_array string_array;
      v_result varchar2(32767);
      v_array_size binary_integer;
      begin
         v_array := to_string_array( );
         v_array_size := cardinality( v_array );
         for i in 1 .. v_array_size  loop
            v_result := v_result || v_array(i) || any_data_formatter.new_line;
         end loop;
         return rtrim( v_result, any_data_formatter.new_line );
      end;

   member function get_self_type_name return varchar2 is
      begin
         return self_type_name;
      end;

   member procedure add_element( self in out nocopy any_data, p_attribute any_data ) is
      begin
         raise_application_error(-2000, 'Feature not available for this type');
      end;

   member function get_element( p_position integer ) return any_data is
      begin
         return self;
      end;

   member function get_elements_count return integer is
      begin
         return 1;
      end;

   member function compare_internal( p_left any_data, p_right any_data ) return integer is
      v_result integer;
      c_sql    constant varchar2(32767) := '
            declare
            begin
               :v_result :=
                  case
                     when treat( :p_left as '||p_left.get_self_type_name()||' ).data_value
                        = treat( :p_right as '||p_right.get_self_type_name()||' ).data_value
                     then 0
                     when treat( :p_left as '||p_left.get_self_type_name()||' ).data_value
                        > treat( :p_right as '||p_right.get_self_type_name()||' ).data_value
                     then 1
                     when treat( :p_left as '||p_left.get_self_type_name()||' ).data_value
                        < treat( :p_right as '||p_right.get_self_type_name()||' ).data_value
                     then -1
                  end;
            end;';
      begin
         execute immediate c_sql using out v_result, p_left, p_right;
         return v_result;
      end;

   order member function compare( p_other any_data ) return integer is
      begin
         return
            case
               when p_other is null
               then null
               when self.get_self_family_name() = p_other.get_self_family_name()
               then compare_internal( self, p_other )
            end;
      end;

end;
/

