drop type anydata_helper_base force;
/

create or replace type anydata_helper_base as object (
   element_name        varchar2(400),
   element_raw_data    anydata,
   element_typecode    integer,
   element_anytype_info anytype_info,
   type_name           varchar2(400),
   type_code           integer,
   data_prec_scale     varchar2(400),
   anydata_getter      varchar2(400),
   anydata_converter   varchar2(400),
   string_data_getter  varchar2(400),
member procedure initialize( p_typecode integer, p_type_name varchar2, p_function_suffix varchar2, p_string_data_getter varchar2),
not final member procedure initialize_with_data( p_element_name varchar2, p_element_raw_data anydata ),
not final member function get_type_name return varchar2,
not final member function get_value_as_string return varchar2,
member function get_report
   return varchar2
) not final not instantiable;
/

create or replace type body anydata_helper_base as
   member procedure initialize( p_typecode integer, p_type_name varchar2, p_function_suffix varchar2, p_string_data_getter varchar2) is
      begin
         self.type_name := p_type_name;
         self.element_typecode := p_typecode;
         self.anydata_getter := 'get' || p_function_suffix;
         self.anydata_converter := 'convert' || p_function_suffix;
         self.string_data_getter := p_string_data_getter;
      end;

   not final member procedure initialize_with_data(  p_element_name varchar2, p_element_raw_data anydata ) is
      begin
         self.element_name := UPPER( p_element_name );
         self.element_raw_data := p_element_raw_data;
         self.element_anytype_info := anytype_info( p_element_raw_data );
         self.element_anytype_info.type_name := coalesce( self.element_anytype_info.type_name, self.type_name );
      end;

   not final member function get_type_name
      return varchar2 is
      begin
         return type_name || case when data_prec_scale is not null then '('||data_prec_scale||')' end;
      end;
   not final member function get_value_as_string
      return varchar2 is
      v_result varchar2(32767);
      v_sql    varchar2(32767);
      begin
         v_sql :=
         '  declare
               v_in_data anydata := :p_in_data;
               v_data '||get_type_name()||';
            begin
               if v_in_data.'||self.anydata_getter||'( v_data ) = DBMS_TYPES.NO_DATA then
                  raise NO_DATA_FOUND;
               end if;
               :p_result := '|| replace( string_data_getter, dyn_sql_helper.to_sting_placeholder, 'v_data' ) ||';
            end;';

         execute immediate v_sql using element_raw_data, out v_result;

         return v_result;
      end;
   member function get_report
      return varchar2 is
      begin
         return element_name
            ||'('||element_anytype_info.get_type()||')'
            || ' => '
            || get_value_as_string();
      end;
   end;
/
