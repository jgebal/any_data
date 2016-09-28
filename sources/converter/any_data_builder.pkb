create or replace package body any_data_builder as

   c_type_def         constant varchar2(30) := '{type_name}';
   c_declare          constant varchar2(30) := '{declare}';
   c_code             constant varchar2(30) := '{code}';
   c_getter           constant varchar2(30) := '{getter}';
   c_return           constant varchar2(30) := '{return}';
   c_value            constant varchar2(30) := '{value}';
   c_data             constant varchar2(30) := 'v_data';
   c_indent           constant varchar2(30) := any_data_formatter.indent_string;
   c_nl               constant varchar2(30) := any_data_const.new_line;
   c_bulk_fetch_limit constant integer := 100;

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

   function build_sql( p_type any_type_mapper, p_data_breadcrumb varchar2, p_return_assignment varchar2 := c_indent||':p_out := '||c_value||';', p_level integer := 1 ) return varchar2 is
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
               c_indent||v_out_iter||' integer := 1;'||c_nl||
               c_indent||v_out_tab||' any_data_tab := any_data_tab();'
            ;
            v_code_sql :=
               c_indent||v_out_tab||'.extend( cardinality( '||v_data_breadcrumb||' ) );' || c_nl ||
               c_indent||'while '||v_in_iter||' is not null loop'||c_nl||
                  indent_lines(
                     build_sql(
                        p_type.get_attribute_type(), v_data_breadcrumb||'('||v_in_iter||')',
                        v_out_tab||'( '||v_out_iter||' ) := ' || c_value || ';', p_level + 1
                     ), 2
                  )||c_nl||
                  c_indent||c_indent||v_in_iter||' := '||v_data_breadcrumb||'.next('||v_in_iter||');'||c_nl||
                  c_indent||c_indent||v_out_iter||' := '||v_out_iter||' + 1;'||c_nl||
               c_indent||'end loop;'||c_nl||
               c_indent||v_out||'.set_data_values('||v_out_tab||');'||c_nl
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
                     'else' || c_nl ||
                        indent_lines(
                           build_sql(
                              p_type.get_attribute_type( i ), v_data_breadcrumb,
                              v_out_tab||'.extend;' || c_nl ||
                              v_out_tab ||'('||v_out_tab||'.last ) := ' || c_value || ';', p_level + 1
                           )
                        ) ||c_nl ||
                        c_indent||v_out||'.set_data_values('||v_out_tab||');'|| c_nl ||
                     'end if;' || c_nl
                  );
            end loop;
         else
            v_out := p_type.get_any_data_constructor( v_data_breadcrumb );
         end if;

         if p_type.is_attribute then
            v_return_sql := 'any_data_attribute( ''' || p_type.attribute_name || ''', ' || v_out || ' )';
         else
            v_return_sql := v_out;
         end if;
         v_return_sql := replace( p_return_assignment, c_value, v_return_sql );

         if v_declare_sql is not null then
            v_sql := replace( v_sql, c_declare, v_declare_sql );
            v_sql := replace( v_sql, c_return, v_return_sql );
            v_sql := replace( v_sql, c_code, v_code_sql);
         else
            v_sql := v_return_sql;
         end if;
         return v_sql;
      end;

   function get_conversion_sql( p_any_data anydata ) return varchar2 is
      v_sql  varchar2(32767) := c_outer_sql_block;
      v_any_type any_type_mapper := any_type_mapper( p_any_data );
      begin
         v_sql := replace( v_sql, c_type_def, v_any_type.get_type_unconstrained( ) );
         v_sql := replace( v_sql, c_getter, v_any_type.get_anydata_getter( ) );
         v_sql := replace( v_sql, c_code, indent_lines( build_sql( v_any_type, c_data ) ) );
         return v_sql;
      end;

   function build( p_any_data anydata ) return any_data is
      v_result any_data;
      begin
         execute immediate get_conversion_sql( p_any_data ) using in p_any_data, out v_result;
         return v_result;
      end;

   function get_any_type_mapper( p_column_description dbms_sql.desc_rec3 ) return any_type_mapper is
      v_any_type any_type_mapper;
      begin
         if p_column_description.col_schema_name is not null
            and p_column_description.col_type_name is not null then
            v_any_type := any_type_mapper(
               anytype.getpersistent( p_column_description.col_schema_name, p_column_description.col_type_name )
            );
            v_any_type.attribute_name := p_column_description.col_name;
         else
            v_any_type := any_type_mapper(
               attribute_name     => p_column_description.col_name,
               attribute_type     => null,
               prec               => nullif(p_column_description.col_precision,0),
               scale              => p_column_description.col_scale,
               len                => p_column_description.col_max_len,
               csid               => p_column_description.col_charsetid,
               csfrm              => p_column_description.col_charsetform,
               schema_name        => p_column_description.col_schema_name,
               type_name          => p_column_description.col_type_name,
               version            => null,
               type_code          => any_data_typecode_mapper.get_dbms_sql_mapping( p_column_description.col_type ).dbms_types_type_code,
               attributes_count   => null
            );
         end if;
         return v_any_type;
      end;

   function get_conversion_sql( p_cursor in out nocopy sys_refcursor ) return varchar2 is
      v_cursor_number      integer;
      c_bulk_fetch_limit   integer := 500;
      v_column_count       pls_integer;
      v_column_desc        dbms_sql.desc_tab3;
      v_any_type           any_type_mapper;
      v_field_accessor     varchar2(4000);
      v_anydata_converter  varchar2(30);
      v_record_fields      varchar2(32767);
      v_column_names       varchar2(32767);
      v_result_row_content varchar2(32767);
      v_sql                varchar2(32767);
   begin
      v_cursor_number := dbms_sql.to_cursor_number( p_cursor );
      dbms_sql.describe_columns3( v_cursor_number, v_column_count, v_column_desc );
      p_cursor := dbms_sql.to_refcursor( v_cursor_number );
      for i in 1 .. v_column_count loop
         --get_any_type_for_column
         v_any_type := get_any_type_mapper( v_column_desc(i) );

         v_field_accessor := 'v_cursor_rows(i).' || lower( v_any_type.attribute_name );

         if v_any_type.type_code in ( dbms_types.typecode_object, dbms_types.typecode_varray, dbms_types.typecode_namedcollection, dbms_types.typecode_table ) then
            v_anydata_converter := 'anydata.' || case when v_any_type.type_code = dbms_types.typecode_object then 'convertObject' else 'convertCollection' end;

            v_result_row_content := v_result_row_content || 'any_data_builder.build( ' || v_anydata_converter || '( ' || v_field_accessor || ' ) ),' || c_nl;
         else
            v_result_row_content := v_result_row_content || v_any_type.get_any_data_constructor( v_field_accessor ) || ',' || c_nl;
         end if;
         v_column_names := v_column_names || '''' || v_any_type.attribute_name || ''',' || c_nl;
         v_record_fields := v_record_fields || lower( v_any_type.attribute_name ) || ' ' || lower( v_any_type.get_type_unconstrained() ) || ',' || c_nl;
      end loop;

      v_record_fields := rtrim( v_record_fields, ',' || c_nl );
      v_result_row_content := rtrim( v_result_row_content, ',' || c_nl );
      v_column_names := rtrim( v_column_names, ',' || c_nl );

      v_sql := c_nl ||
               'declare' || c_nl ||
               '   v_cursor        sys_refcursor := :p_cursor;' || c_nl ||
               '   type t_cursor_row is record( ' || c_nl ||
                      indent_lines( v_record_fields, 2 ) || c_nl ||
               '   );' || c_nl ||
               '   type t_cursor_rows is table of t_cursor_row;' || c_nl ||
               '   v_cursor_rows   t_cursor_rows;' || c_nl ||
               '   v_column_names  string_array := string_array();' || c_nl ||
               '   v_result_rows   any_data_tab := any_data_tab();' || c_nl ||
               '   v_row_number    integer := 1;' || c_nl ||
               'begin' || c_nl ||
               '   v_column_names := string_array( ' || c_nl ||
                         indent_lines( v_column_names, 2 ) || c_nl ||
               '   );' || c_nl ||
               '   loop' || c_nl ||
               '      fetch v_cursor bulk collect into v_cursor_rows limit ' || c_bulk_fetch_limit || ';' || c_nl ||
               '      v_result_rows.extend( v_cursor_rows.count );' || c_nl ||
               '      for i in 1 .. v_cursor_rows.count loop ' || c_nl ||
               '         v_result_rows( v_row_number ) := any_data_result_row(' || c_nl ||
               '            any_data_tab(' || c_nl ||
                               indent_lines( v_result_row_content, 5 ) || c_nl ||
               '            )' || c_nl ||
               '         );' || c_nl ||
               '         v_row_number := v_row_number + 1;' || c_nl ||
               '      end loop;' || c_nl ||
               '   exit when v_cursor%notfound;' || c_nl ||
               '   end loop;' || c_nl ||
               '   :v_result := any_data_result_set( v_result_rows, v_column_names );' || c_nl ||
               '   close v_cursor;'|| c_nl ||
               'end;'|| c_nl
      ;

      return v_sql;
   end;


   function build( p_cursor sys_refcursor ) return any_data is
      v_cursor sys_refcursor := p_cursor;
      v_result any_data;
      begin
         execute immediate get_conversion_sql( v_cursor ) using in v_cursor, out v_result;
         return v_result;
      end;


end;
/
