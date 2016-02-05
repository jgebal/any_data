drop type any_data_collection force;
/

create or replace type any_data_collection under any_data(
   data_values     any_data_tab,
   member procedure add_element( self in out nocopy any_data_collection, p_element any_data ),
   member function get_element( p_position integer ) return any_data,
   member function get_elements_count return integer,
   overriding member function to_string return varchar2,
   overriding member procedure initialise( self in out nocopy any_data_collection, p_data anydata ),
   constructor function any_data_collection( p_type_code integer ) return self as result
);
/

create or replace type body any_data_collection as

   member function get_elements_count return integer is
      begin
        return coalesce( cardinality( data_values ), 0 );
      end;

   member function get_element( p_position integer ) return any_data is
      begin
         return data_values( p_position );
      end;

   member procedure add_element( self in out nocopy any_data_collection, p_element any_data ) is
      begin
         data_values.extend;
         data_values( data_values.last ) := p_element;
      end;

   overriding member function to_string return varchar2 is
      v_result varchar2(32767);
      values_count  integer := get_elements_count();
      begin
         v_result := self.type_info.get_type_name() || '(' || anydata_helper.new_line;
         for i in 1 .. values_count loop
            v_result := v_result ||
                        anydata_helper.indent_lines(
                           data_values(i).to_string() || case when i < values_count then ',' end
                        ) || anydata_helper.new_line;
         end loop;

         return v_result || ')';
      end;

   overriding member procedure initialise( self in out nocopy any_data_collection, p_data anydata ) is
      v_sql       varchar2(32767);
      v_builder   any_data_builder;
      v_template  any_data;
      v_tmp_obj   any_data_collection;
      begin
         v_builder := any_data_builder( p_data );

         v_template := v_builder.get_element(1);

         self.type_info.set_type_name( v_builder.type_info.get_type() );

         v_tmp_obj := self;

         v_sql := '
            declare
               v_data          anydata             := :p_data;
               v_template      any_data            := :p_template;
               v_obj           any_data_collection := :p_obj;
               v_collection    ' || v_builder.type_info.get_type() || ';
               i               integer;
            begin
               if v_data.getCollection( v_collection ) = DBMS_TYPES.NO_DATA then
                  raise NO_DATA_FOUND;
               end if;
               i := v_collection.first;
               while i is not null loop
                  v_template.initialise( anydata.'||v_template.type_info.converter_func_name()||'( v_collection(i) ) );
                  v_obj.add_element( v_template );
                  i := v_collection.next(i);
               end loop;
               :p_result := v_obj;
            end;';
         execute immediate v_sql using in p_data, in v_template, in v_tmp_obj, out v_tmp_obj;
         self := v_tmp_obj;

      end;

   constructor function any_data_collection( p_type_code integer ) return self as result is
      begin
         self.type_info := any_type( p_type_code, 'COLLECTION' );
         data_values := any_data_tab();
         return;
      end;

end;
/

