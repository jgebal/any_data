drop type any_data_collection force;
/

create or replace type any_data_collection under any_data_compound(
   overriding member procedure initialise( self in out nocopy any_data_collection, p_data anydata ),
   constructor function any_data_collection( p_type_code integer ) return self as result
);
/

create or replace type body any_data_collection as

   overriding member procedure initialise( self in out nocopy any_data_collection, p_data anydata ) is
      v_sql       varchar2(32767);
      v_builder   any_data_builder;
      v_template  any_data;
      v_tmp_obj   any_data_collection;
      begin
         v_builder := any_data_builder( p_data );

         v_template := v_builder.get_element(1);

         self.type_info.set_type_name( v_builder.type_helper.get_type() );

         v_tmp_obj := self;

         v_sql := '
            declare
               v_data          anydata             := :p_data;
               v_template      any_data            := :p_template;
               v_obj           any_data_collection := :p_obj;
               v_collection    ' || v_builder.type_helper.get_type() || ';
               i               integer;
            begin
               if v_data.getCollection( v_collection ) = DBMS_TYPES.NO_DATA then
                  raise NO_DATA_FOUND;
               end if;
               i := v_collection.first;
               while i is not null loop
                  v_template.initialise( anydata.'||v_template.get_type().converter_func_name()||'( v_collection(i) ) );
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

