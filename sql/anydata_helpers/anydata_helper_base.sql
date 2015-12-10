drop type anydata_helper_base force;
/

create or replace type anydata_helper_base as object (
   element_typecode    integer,
   type_name           varchar2(400),
   data_prec_scale     varchar2(400),
   anydata_getter      varchar2(400),
   anydata_converter   varchar2(400),
   string_data_getter  varchar2(400),
member procedure initialize( p_element_typecode integer, p_type_name varchar2, p_anydata_function_suffix varchar2, p_string_data_getter varchar2),
member function get_type_name return varchar2,
not final member function get_report( p_data anydata )
   return varchar2
) not final not instantiable;
/

create or replace type body anydata_helper_base as
   member procedure initialize( p_element_typecode integer, p_type_name varchar2, p_anydata_function_suffix varchar2, p_string_data_getter varchar2) is
      begin
         self.type_name := p_type_name;
         self.element_typecode := p_element_typecode;
         self.anydata_getter := 'get' || p_anydata_function_suffix;
         self.anydata_converter := 'convert' || p_anydata_function_suffix;
         self.string_data_getter := p_string_data_getter;
      end;
   member function get_type_name
      return varchar2 is
      begin
         return type_name || case when data_prec_scale is not null then '('||data_prec_scale||')' end;
      end;
   not final member function get_report( p_data anydata )
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
               :p_result := '||REPLACE(string_data_getter,anytype_helper_const.anydata_getter_place,'v_data')||';
            end;';
          execute immediate v_sql using p_data, out v_result;
          return v_result;
--         return v_sql;
      end;
   end;
/
