create or replace package body any_data_builder as

   c_type_def constant varchar2(30) := '{type_name}';
   c_declare  constant varchar2(30) := '{declare}';
   c_code     constant varchar2(30) := '{code}';
   c_getter   constant varchar2(30) := '{getter}';
   c_return   constant varchar2(30) := '{return}';
   c_value    constant varchar2(30) := '{value}';
   c_data     constant varchar2(30) := 'v_data';
   c_indent   constant varchar2(30) := any_data_formatter.indent_string;
   c_nl       constant varchar2(30) := any_data_const.new_line;

   c_sql_block constant varchar2(1000) :=
      'declare'||c_nl||
      c_declare||c_nl||
      'begin'||c_nl||
      c_code||
      c_return||c_nl||
      'end;';
   c_outer_sql_block constant varchar2(1000) :=
      'declare'||c_nl||
      c_indent||'v_input anydata := :p_input;'||c_nl||
      c_indent||c_data||' ' || c_type_def || ';' || c_nl ||
      'begin'||c_nl||
      c_indent||'if v_input.get'||c_getter||'( '||c_data||' ) = DBMS_TYPES.NO_DATA then'||c_nl||
      '      raise NO_DATA_FOUND;'||c_nl||
      c_indent||'end if;'||c_nl||
      c_code||c_nl||
      'end;';

   function get_version return varchar2 is
      begin
         return '&&VERSION';
      end;

   function indent_lines( p_string varchar2, p_times integer := 1 ) return varchar2 is
      begin
        return any_data_formatter.indent_lines( p_string, p_times );
      end;

   function build_sql( p_type any_type_mapper, p_data_breadcrumb varchar2, p_return_assignment varchar2 := ':p_out := '||c_value||';', p_level integer := 1 ) return varchar2 is
      v_sql               varchar2(32767) := c_sql_block;
      v_declare_sql       varchar2(1000);
      v_return_sql        varchar2(1000);
      v_code_sql          varchar2(32767);
      v_data_breadcrumb   varchar2(4000) := p_data_breadcrumb;
      v_out               varchar2(1000) := 'v_out_'||p_level;
      v_out_tab           varchar2(1000) := 'v_out_tab_'||p_level;
      v_anydata           varchar2(30)   := 'v_anydata_'||p_level;
      v_any_type          varchar2(30)   := 'v_any_type_'||p_level;
      v_in_iter           varchar2(30)   := 'i_'||p_level;
      v_out_iter          varchar2(30)   := 'o_'||p_level;
      begin
         if p_type.is_attribute then
            v_data_breadcrumb  := p_data_breadcrumb||'.' || p_type.attribute_name;
         end if;

         if p_type.type_code in ( dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection ) then
            v_declare_sql :=
               c_indent||v_out||' any_data_collection := '||p_type.get_any_data_constructor( 'any_data_tab()' )||';'||c_nl||
               c_indent||v_in_iter||' integer := '||v_data_breadcrumb||'.first;'||c_nl||
               c_indent||v_out_iter||' integer := 1;'
            ;
            v_code_sql :=
               c_indent||v_out||'.data_values'||'.extend( cardinality( '||v_data_breadcrumb||' ) );' || c_nl ||
               c_indent||'while '||v_in_iter||' is not null loop'||c_nl||
               indent_lines(
                  build_sql(
                     p_type.get_attribute_type(), v_data_breadcrumb||'('||v_in_iter||')',
                     v_out||'.data_values'||'( '||v_out_iter||' ) := ' || c_value || ';', p_level + 1
--                     v_out||'.add_element('||c_value||');', p_level + 1
                  ), 2
               )||c_nl||
               c_indent||c_indent||v_in_iter||' := '||v_data_breadcrumb||'.next('||v_in_iter||');'||c_nl||
               c_indent||c_indent||v_out_iter||' := '||v_out_iter||' + 1;'||c_nl||
               c_indent||'end loop;'||c_nl
            ;
         elsif p_type.type_code = dbms_types.typecode_object then
            v_declare_sql :=
               c_indent||v_out||' any_data_object := '||p_type.get_any_data_constructor( 'NULL' )||';'||c_nl||
               c_indent||v_anydata||' anydata := anydata.convertObject( '||v_data_breadcrumb || ' );'||c_nl||
               c_indent||v_out_tab||' any_data_tab := any_data_tab();'
            ;
            for i in 1 .. p_type.attributes_count loop
               v_code_sql := v_code_sql ||
                  indent_lines(
                     'if ' || v_anydata || '.gettypename() != ''' || p_type.get_typename( ) || ''' then' || c_nl ||
                     c_indent || v_out || ' := treat( any_data_builder.build( ' || v_anydata || ' ) as any_data_object);' || c_nl ||
                     'else' ||
                     indent_lines(
                        build_sql(
                           p_type.get_attribute_type( i ), v_data_breadcrumb,
                           v_out_tab||'.extend;' || c_nl || v_out_tab ||'('||v_out_tab||'.last ) := ' || c_value || ';', p_level + 1
--                           v_out || '.add_element(' || c_value || ');', p_level + 1
                        )||c_nl ||
                        c_indent||v_out||'.data_values := '||v_out_tab||';'
                     ) || c_nl ||
                     'end if;' || c_nl
                  );
            end loop;
         else
--             v_out := p_type.get_any_data_object_name() || '(' || v_data_breadcrumb || ')';
            v_out := p_type.get_any_data_constructor( v_data_breadcrumb );
         end if;

         if p_type.is_attribute then
            v_return_sql := 'any_data_attribute( NULL, NULL, ''any_data_attribute'', ''' || p_type.attribute_name || ''', ' || v_out || ' )';
         else
            v_return_sql := v_out;
         end if;
         v_return_sql := replace( p_return_assignment, c_value, v_return_sql );

         if v_declare_sql is not null then
            v_sql := replace( v_sql, c_declare, v_declare_sql );
            v_sql := replace( v_sql, c_return, c_indent||v_return_sql );
            v_sql := replace( v_sql, c_code, v_code_sql);
         else
            v_sql := v_return_sql;
         end if;
         return v_sql;
      end;

   function get_conversion_sql( p_type any_type_mapper ) return varchar2 is
      v_sql varchar2(32767) := c_outer_sql_block;
      begin
         v_sql := replace( v_sql, c_type_def, p_type.get_type( ) );
         v_sql := replace( v_sql, c_getter, p_type.get_anydata_getter( ) );
         v_sql := replace( v_sql, c_code, indent_lines( build_sql( p_type, c_data ) ) );
         return v_sql;
      end;

   function build( p_any_data anydata, p_any_type any_type_mapper ) return any_data is
      v_result any_data;
      begin
         execute immediate get_conversion_sql( p_any_type ) using in p_any_data, out v_result;
         return v_result;
      end;

   function build( p_any_data anydata ) return any_data is
      begin
         return build( p_any_data, any_type_mapper( p_any_data ) );
      end;

end;
/
