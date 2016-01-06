drop type anydata_helper_object force;
/

create or replace type anydata_helper_object under anydata_helper_base (
constructor function anydata_helper_object return self as result,
overriding member function get_value_as_string return varchar2,
overriding member function get_sql_for_value_string return varchar2,
member function get_sql_for_attribute( pv_position integer ) return varchar2
);
/

create or replace type body anydata_helper_object as
   constructor function anydata_helper_object return self as result is
      begin
         self.initialize( 'Object',
                          '''{'' || chr(10) || ' || dyn_sql_helper.to_sting_placeholder || ' || chr( 10 ) || ''}'''
         );
         return;
      end;
   overriding member function get_sql_for_value_string return varchar2 is
      v_sql    varchar2(32767);
      begin
         v_sql := '
            declare
               v_in_anydata_helper        anydata_helper_base := :p_in_data;
               v_in_data                  anydata := v_in_anydata_helper.element_raw_data;
               v_result                   varchar2(32767);
               v_attribute_anydata_helper anydata_helper_base;
            begin
               v_in_data.piecewise();';
         for i in 1 .. element_anytype_info.count loop
            v_sql := v_sql ||get_sql_for_attribute( i );
         end loop;

--          for i in 1 .. element_anytype_info.count loop
--             v_sql := v_sql ||'
--                for i in 1 .. v_in_anydata_helper.element_anytype_info.count loop
--                  v_attribute_anydata_helper := v_in_anydata_helper.element_anytype_info(i);
--                end loop;';
--             v_attribute_type_info := self.element_anytype_info.get_child_type_info( i );
--             v_attribute_anydata_helper := anydata_helper_base.construct( v_attribute_type_info.type_code );
--             v_attribute_anydata_helper.element_anytype_info := v_attribute_type_info;
--             v_attribute_anydata_helper.element_name := upper(v_attribute_type_info.attribute_name);
--             --TODO add usage of anydata_helper_base inside dynamic SQL to get results
--             v_sql := v_sql
--                      || v_attribute_anydata_helper.get_sql_for_value_as_string(
--                         'v_result := v_result || '''
--                         ||v_attribute_anydata_helper.element_name
--                         ||'('||v_attribute_anydata_helper.get_type_name||') => ''||',
--                         'v_in_data'
--                      );
--             if i <> element_anytype_info.count then
--                v_sql := v_sql || '
--                v_result := v_result || '','' || chr(10);';
--             end if;
--          end loop;
         v_sql := v_sql || '
               :p_result := ' ||
                  replace( string_data_getter, dyn_sql_helper.to_sting_placeholder, 'v_result' ) ||';
            end;';
         return v_sql;
      end;
overriding member function get_value_as_string
      return varchar2 is
      v_result varchar2(32767);
      begin
--         return get_sql_for_value_string();
         execute immediate get_sql_for_value_string( ) using self, out v_result;
         return v_result;
      end;
member function get_sql_for_attribute( pv_position integer ) return varchar2 is
      v_attribute_type_info      anytype_info;
      v_attribute_anydata_helper anydata_helper_base;
      begin
         v_attribute_type_info := self.get_child_type_info( pv_position );
         v_attribute_anydata_helper := anydata_helper_base.construct( v_attribute_type_info.type_code );
--          v_attribute_anydata_helper.element_anytype_info := v_attribute_type_info;
--          v_attribute_anydata_helper.element_name := upper(v_attribute_type_info.attribute_name);
         return
            replace(
               replace(
                  v_attribute_anydata_helper.get_sql_for_piecewise_string( ),
                  dyn_sql_helper.piecewise_pos_placeholder,
                  pv_position
               ),
               dyn_sql_helper.typecode_placeholder,
               v_attribute_type_info.type_code
            )
            || case
               when element_anytype_info.count != pv_position
               then '
               v_result := v_result || '','' || chr(10);'
               end;
      end;
end;
/
