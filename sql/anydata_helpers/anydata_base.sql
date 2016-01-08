drop type anydata_base force;
/

create or replace type anydata_base as object (
   element_name         varchar2(400),
   element_raw_data     anydata,
   type_info            anytype_info,
   anydata_getter       varchar2(400),
   anydata_converter    varchar2(400),
   string_data_getter   varchar2(4000),
member function get_sql_for_value_string return varchar2,
member function get_value_as_string return varchar2,
member function get_report return varchar2,
member function get_type_def return varchar2,
final member function get_type return varchar2,
final member function get_typename return varchar2,
final member procedure initialize( p_function_suffix varchar2, p_string_data_getter varchar2 ),
final member procedure initialize_with_data( p_element_name varchar2, p_element_raw_data anydata ),
final member procedure initialize_with_data( p_element_raw_data anydata, p_element_type_info anytype_info ),
final member function get_data_getter_sql return varchar2,
final member function get_sql_for_piecewise_string return varchar2,
final member function get_child_type_info( pv_child_position pls_integer ) return anytype_info,
final member procedure set_datatype_length( p_length integer),
final static function construct( p_type_code integer ) return anydata_base,
final static function construct( p_field_name varchar2, p_field_value anydata ) return anydata_base,
constructor function anydata_base( p_function_suffix varchar2, p_string_data_getter varchar2 ) return self as result
) not final;
/

create or replace type body anydata_base as

member function get_sql_for_value_string return varchar2 is
      begin
         return '
            declare
               v_anydata_base      anydata_base := :p_in_data;
               v_anydata           anydata := v_anydata_base.element_raw_data;
               v_data ' || get_type_def( ) || ';
            begin
               ' || get_data_getter_sql( ) || '
               :p_result := ' || replace( string_data_getter, anydata_helper.to_sting_placeholder, 'v_data' ) || ';
            end;';
      end;

member function get_value_as_string
      return varchar2 is
      v_result varchar2(32767);
      begin
         execute immediate get_sql_for_value_string( ) using self, out v_result;
         return v_result;
      end;

member function get_report return varchar2 is
      begin
         return element_name || '(' || get_type( ) || ')' || ' => ' || get_value_as_string( );
      end;

member function get_type_def return varchar2 is
      begin
         return get_type( );
      end;

final member function get_type return varchar2 is
      begin
         return type_info.get_type( );
      end;

final member function get_typename return varchar2 is
      begin
         return type_info.get_typename( );
      end;

final member procedure initialize( p_function_suffix varchar2, p_string_data_getter varchar2 ) is
      begin
         self.anydata_getter := 'get' || p_function_suffix;
         self.anydata_converter := 'convert' || p_function_suffix;
         self.string_data_getter := p_string_data_getter;
      end;

final member procedure initialize_with_data( p_element_name varchar2, p_element_raw_data anydata ) is
      begin
         self.element_name := p_element_name;
         self.element_raw_data := p_element_raw_data;
         self.type_info := anytype_info( p_element_raw_data );
      end;

final member procedure initialize_with_data( p_element_raw_data anydata, p_element_type_info anytype_info ) is
      begin
         self.element_raw_data := p_element_raw_data;
         self.type_info := p_element_type_info;
         self.element_name := self.type_info.attribute_name;
      end;

final member function get_data_getter_sql return varchar2 is
      begin
         return 'if v_anydata.' || self.anydata_getter || '( v_data ) = DBMS_TYPES.NO_DATA then
                     raise NO_DATA_FOUND;
                  end if;';

      end;

final member function get_sql_for_piecewise_string return varchar2 is
      begin
         return '
               declare
                  v_data ' || get_type_def( ) || ';
                  v_attribute_anydata anydata_base := anydata_base.construct(' || anydata_helper.typecode_placeholder || ');
               begin
                  ' || get_data_getter_sql( ) || '
                  v_attribute_anydata.initialize_with_data(
                     anydata.' || anydata_converter || '(v_data),
                     v_anydata_base.get_child_type_info(' || anydata_helper.piecewise_pos_placeholder || ')
                  );
                  v_result := v_result || v_attribute_anydata.get_report();
               end;';
      end;

final member function get_child_type_info( pv_child_position pls_integer )
      return anytype_info is
      begin
         return anytype_info( pv_child_position, self.type_info.attribute_type );
         exception when others then
         raise_Application_error(
            -20000,
            'pv_child_position=' || pv_child_position
            || 'self.type_info.type_name=' || self.type_info.type_name
         );
      end;

final member procedure set_datatype_length( p_length integer) is
      begin
         type_info.len := p_length;
      end;
final static function construct( p_type_code integer ) return anydata_base is
      v_result anydata_base;
      begin
         case
            when p_type_code = dbms_types.typecode_number
            then v_result := anydata_base(
               'Number',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder )
            );
            when p_type_code = dbms_types.typecode_date
            then v_result := anydata_base(
               'Date',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder, 'YYYY-MM-DD HH24:MI:SS' ));
            when p_type_code = dbms_types.typecode_timestamp
            then v_result := anydata_base(
               'Timestamp',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder,
                                       'YYYY-MM-DD HH24:MI:SSxFF TZH:TZM')
            );
            when p_type_code = dbms_types.typecode_timestamp_tz
            then v_result := anydata_base(
               'TimestampTZ',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder,
                                       'YYYY-MM-DD HH24:MI:SSxFF TZH:TZM')
            );
            when p_type_code = dbms_types.typecode_timestamp_ltz
            then v_result := anydata_base(
               'TimestampLTZ',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder,
                                       'YYYY-MM-DD HH24:MI:SSxFF TZH:TZM')
            );
            when p_type_code = dbms_types.typecode_interval_ym
            then v_result := anydata_base(
               'IntervalYM',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder )
            );
            when p_type_code = dbms_types.typecode_interval_ds
            then v_result := anydata_base(
               'IntervalDS',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder )
            );
            when p_type_code = dbms_types.typecode_char
            then v_result := anydata_char( 'Char' );
            when p_type_code = dbms_types.typecode_varchar2
            then v_result := anydata_char( 'Varchar2' );
            when p_type_code = dbms_types.typecode_varchar
            then v_result := anydata_char( 'Varchar' );
            when p_type_code = dbms_types.typecode_nchar
            then v_result := anydata_char( 'Nchar' );
            when p_type_code = dbms_types.typecode_nvarchar2
            then v_result := anydata_char( 'NVarchar2' );
            when p_type_code = dbms_types.typecode_raw
            then v_result := anydata_base(
               'Raw',
               anydata_helper.to_char(
                  anydata_helper.utl_raw_cast_to_varchar2(
                     anydata_helper.to_sting_placeholder
                  )
               )
            );
            when p_type_code = dbms_types.typecode_blob
            then v_result := anydata_base(
               'Blob',
               anydata_helper.utl_raw_cast_to_varchar2(
                  anydata_helper.dbms_lob_substr(
                     anydata_helper.to_sting_placeholder,
                     anydata_helper.max_return_data_length )
               )
            );
            when p_type_code = dbms_types.typecode_bfile
            then v_result := anydata_base(
               'Bfile',
               anydata_helper.utl_raw_cast_to_varchar2(
                  anydata_helper.dbms_lob_substr(
                     anydata_helper.to_sting_placeholder,
                     anydata_helper.max_return_data_length )
               )
            );
            when p_type_code = dbms_types.typecode_clob
            then v_result := anydata_base(
               'Clob',
               anydata_helper.to_char(
                  anydata_helper.dbms_lob_substr(
                     anydata_helper.to_sting_placeholder,
                     anydata_helper.max_return_data_length
                  )
               )
            );
            when p_type_code = dbms_types.typecode_cfile
            then v_result := anydata_base(
               'Cfile',
               anydata_helper.dbms_lob_substr(
                  anydata_helper.to_sting_placeholder,
                  anydata_helper.max_return_data_length )
            );
            when p_type_code = dbms_types.typecode_nclob
            then v_result := anydata_base(
               'NClob',
               anydata_helper.to_char(
                  anydata_helper.dbms_lob_substr(
                     anydata_helper.to_sting_placeholder,
                     anydata_helper.max_return_data_length
                  )
               )
            );
            when p_type_code = dbms_types.typecode_bfloat
            then v_result := anydata_base(
               'BFloat',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder )

            );
            when p_type_code = dbms_types.typecode_bdouble
            then v_result := anydata_base(
               'BDouble',
               anydata_helper.to_char( anydata_helper.to_sting_placeholder )

            );
            when p_type_code = dbms_types.typecode_object
            then v_result := anydata_object( );
            when p_type_code in ( dbms_types.typecode_varray, dbms_types.typecode_table, dbms_types.typecode_namedcollection )
            then v_result := anydata_collection( );
         end case;
         v_result.type_info := anytype_info( p_type_code );
         return v_result;
      end;

final static function construct( p_field_name varchar2, p_field_value anydata ) return anydata_base is
      v_type    anytype;
      v_anydata anydata_base;
      begin
         v_anydata := anydata_base.construct( p_field_value.gettype( v_type ) );
         v_anydata.initialize_with_data( p_field_name, p_field_value );
         return v_anydata;
      end;
constructor function anydata_base( p_function_suffix varchar2, p_string_data_getter varchar2 ) return self as result is
   begin
      initialize( p_function_suffix, p_string_data_getter);
      return;
   end;
end;
/
