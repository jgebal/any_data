create or replace type any_data authid current_user as object(
   type_code      number(38, 0),
   type_name      varchar2(100),
   self_type_name varchar2(100),
static function get_version return varchar2,
final member function to_string return varchar2,
not instantiable member function to_string_array( p_separator varchar2 := null ) return string_array,
not instantiable member function get_self_family_name return varchar2,
member function get_self_type_name return varchar2,
member procedure add_element( self in out nocopy any_data, p_attribute any_data ),
member function get_element( p_position integer ) return any_data,
member function get_elements_count return integer,
member function compare_internal( p_other any_data ) return integer,
order member function compare( p_other any_data ) return integer,
member function equals( p_other any_data ) return boolean,
final member function not_equals( p_other any_data ) return boolean,
member function greater_than( p_other any_data ) return boolean,
member function less_than( p_other any_data ) return boolean,
member function greater_equal_to( p_other any_data ) return boolean,
member function less_equal_to( p_other any_data ) return boolean,
final member function eq( p_other any_data ) return boolean,
final member function "= "( p_other any_data ) return boolean,
final member function neq( p_other any_data ) return boolean,
final member function "!="( p_other any_data ) return boolean,
final member function "<>"( p_other any_data ) return boolean,
final member function gt( p_other any_data ) return boolean,
final member function "> "( p_other any_data ) return boolean,
final member function lt( p_other any_data ) return boolean,
final member function "< "( p_other any_data ) return boolean,
final member function ge( p_other any_data ) return boolean,
final member function ">="( p_other any_data ) return boolean,
final member function le( p_other any_data ) return boolean,
final member function "<="( p_other any_data ) return boolean
) not final not instantiable;
/

create or replace type body any_data as

   static function get_version return varchar2 is
      begin
         return '&&VERSION';
      end;

   final member function to_string return varchar2 is
      v_array string_array;
      v_result varchar2(32767);
      v_array_size binary_integer;
      begin
         v_array := to_string_array( );
         v_array_size := cardinality( v_array );
         for i in 1 .. v_array_size  loop
            v_result := v_result || v_array(i) || any_data_const.new_line;
         end loop;
         return rtrim( v_result, any_data_const.new_line );
      end;

   member function get_self_type_name return varchar2 is
      begin
         return self_type_name;
      end;

   member procedure add_element( self in out nocopy any_data, p_attribute any_data ) is
      begin
         raise_application_error( -20000, 'Feature not available for ' || get_self_type_name( ) || ' type' );
      end;

   member function get_element( p_position integer ) return any_data is
      begin
         return self;
      end;

   member function get_elements_count return integer is
      begin
         return 1;
      end;

   member function compare_internal( p_other any_data ) return integer is
      v_result integer;
      c_sql    constant varchar2(32767) := '
            declare
               function do_compare(
                  p_self '  || self.get_self_type_name( ) || ',
                  p_other ' || p_other.get_self_type_name( ) || '
               ) return integer is
               begin
                  return
                     case
                        when any_data_const.nulls_are_equal
                         and p_self.data_value is null and p_other.data_value is null then 0
                        when p_self.data_value = p_other.data_value then 0
                        when p_self.data_value > p_other.data_value then 1
                        when p_self.data_value < p_other.data_value then -1
                     end;
               end;
            begin
               :v_result :=
                  do_compare(
                     treat( :v_self  as ' || self.get_self_type_name( ) || ' ),
                     treat( :p_other as ' || p_other.get_self_type_name( ) || ' )
                  );
            end;';
      begin
         execute immediate c_sql using out v_result, self, p_other;
         return v_result;
      end;

   order member function compare( p_other any_data ) return integer is
      begin
         return
            case
               when p_other is null
               then null
               when self.get_self_family_name() = p_other.get_self_family_name()
               then compare_internal( p_other )
            end;
      end;

   member function equals( p_other any_data ) return boolean is
      begin
          return coalesce( compare( p_other ) = 0, false );
      end;

   final member function not_equals( p_other any_data ) return boolean is
      begin
         return coalesce( compare( p_other ) != 0, false );
      end;

   member function greater_than( p_other any_data ) return boolean is
      begin
         return coalesce( compare( p_other ) > 0, false );
      end;

   member function less_than( p_other any_data ) return boolean is
      begin
         return coalesce( compare( p_other ) < 0, false );
      end;

   member function greater_equal_to( p_other any_data ) return boolean is
      begin
         return coalesce( compare( p_other ) >= 0, false );
      end;

   member function less_equal_to( p_other any_data ) return boolean is
      begin
         return coalesce( compare( p_other ) <= 0, false );
      end;

   final member function eq( p_other any_data ) return boolean is
      begin
         return equals( p_other );
      end;

   final member function "= "( p_other any_data ) return boolean is
      begin
         return equals( p_other );
      end;

   final member function neq( p_other any_data ) return boolean is
      begin
         return not_equals( p_other );
      end;

   final member function "!="( p_other any_data ) return boolean is
      begin
         return not_equals( p_other );
      end;

   final member function "<>"( p_other any_data ) return boolean is
      begin
         return not equals( p_other );
      end;

   final member function gt( p_other any_data ) return boolean is
      begin
         return greater_than( p_other );
      end;

   final member function "> "( p_other any_data ) return boolean is
      begin
         return greater_than( p_other );
      end;

   final member function lt( p_other any_data ) return boolean is
      begin
         return less_than( p_other );
      end;

   final member function "< "( p_other any_data ) return boolean is
      begin
         return less_than( p_other );
      end;

   final member function ge( p_other any_data ) return boolean is
      begin
         return greater_equal_to( p_other );
      end;

   final member function ">="( p_other any_data ) return boolean is
      begin
         return greater_equal_to( p_other );
      end;

   final member function le( p_other any_data ) return boolean is
      begin
         return less_equal_to( p_other );
      end;

   final member function "<="( p_other any_data ) return boolean is
      begin
         return less_equal_to( p_other );
      end;

end;
/

