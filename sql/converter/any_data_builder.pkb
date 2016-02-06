create or replace package body any_data_builder as

   c_type_name constant varchar2(30) := '{type_name}';
   c_declare   constant varchar2(30) := '{declare}';
   c_code      constant varchar2(30) := '{code}';
   c_getter    constant varchar2(30) := '{getter}';
   c_return    constant varchar2(30) := '{return}';
   c_value     constant varchar2(30) := '{value}';
   c_data      constant varchar2(30) := 'v_data';

   c_sql_block constant varchar2(1000) :=
      'declare'||any_data_formatter.new_line||
      c_declare||any_data_formatter.new_line||
      'begin'||any_data_formatter.new_line||
      c_code||
      c_return||any_data_formatter.new_line||
      'end;';
   c_outer_sql_block constant varchar2(1000) :=
      'declare'||any_data_formatter.new_line||
      '   v_input anydata := :p_input;'||any_data_formatter.new_line||
      '   '||c_data||' '||c_type_name||';'||any_data_formatter.new_line||
      'begin'||any_data_formatter.new_line||
      '   if v_input.get'||c_getter||'( '||c_data||' ) = DBMS_TYPES.NO_DATA then'||any_data_formatter.new_line||
      '      raise NO_DATA_FOUND;'||any_data_formatter.new_line||
      '   end if;'||any_data_formatter.new_line||
      '   '||c_code||any_data_formatter.new_line||
      'end;';

   function build_sql( p_type any_type_mapper, p_data_breadcrumb varchar2, p_level integer := 1, p_return_assignment varchar2 := ':p_out := '||c_value||';' ) return varchar2 is
      v_sql               varchar2(32767) := c_sql_block;
      v_return_assignment varchar2(1000) := p_return_assignment;
      v_declare_sql       varchar2(1000);
      v_return_sql        varchar2(1000);
      v_code_sql          varchar2(32767);
      v_data_breadcrumb   varchar2(4000) := p_data_breadcrumb;
      v_out               varchar2(1000) := 'v_out_'||p_level;
      v_iter              varchar2(30)  := 'i'||p_level;
      begin
         if p_type.is_attribute then
            v_data_breadcrumb  := p_data_breadcrumb||'.' || p_type.attribute_name;
         else
            v_data_breadcrumb  := p_data_breadcrumb;
         end if;

         if p_type.type_code in ( dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection ) then
            v_declare_sql :=
               v_out||' '||p_type.get_any_data_object_name()||' := '||p_type.get_any_data_object_name()||'('''||p_type.get_typename()||''', '||p_type.type_code||');'||any_data_formatter.new_line||
               v_iter||' integer := '||p_data_breadcrumb||'.first;'
            ;
            v_data_breadcrumb := v_data_breadcrumb||'('||v_iter||')';
            v_code_sql :=
               'while '||v_iter||' is not null loop'||any_data_formatter.new_line||
               build_sql( p_type.get_attribute_type( 1 ), v_data_breadcrumb, p_level + 1, v_out||'.add_element('||c_value||');' )||any_data_formatter.new_line||
               v_iter||' := '||p_data_breadcrumb||'.next('||v_iter||');'||any_data_formatter.new_line||
               'end loop;'||any_data_formatter.new_line;
         elsif p_type.type_code = dbms_types.typecode_object then
            v_declare_sql := v_out || ' ' ||p_type.get_any_data_object_name()||' := '||p_type.get_any_data_object_name() || '(''' || p_type.get_typename() || ''');';
            for i in 1 .. p_type.attributes_count loop
               v_code_sql := v_code_sql
                             || build_sql( p_type.get_attribute_type( i ), v_data_breadcrumb, p_level + 1, v_out||'.add_element('||c_value||');' )||any_data_formatter.new_line;
            end loop;
         else
             v_out := p_type.get_any_data_object_name() || '(' || v_data_breadcrumb || ')';
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

   function get_conversion_sql( p_type any_type_mapper ) return varchar2 is
      v_sql varchar2(32767) := c_outer_sql_block;
      begin
         v_sql := replace( v_sql, c_type_name, p_type.get_typename( ) );
         v_sql := replace( v_sql, c_getter, p_type.get_anydata_getter( ) );
         v_sql := replace( v_sql, c_code, build_sql( p_type, c_data ) );
         return v_sql;
      end;

   function build( p_any_data anydata ) return any_data is
      v_sql    varchar2(32767);
      v_result any_data;
      begin
         v_sql := get_conversion_sql( any_type_mapper( p_any_data ) );
         execute immediate v_sql using in p_any_data, out v_result;
         return v_result;
      end;
end;
/
