drop type any_data_object force;
/

create or replace type any_data_object under any_data_compound(
   overriding member procedure initialise( self in out nocopy any_data_object, p_data anydata ),
   constructor function any_data_object return self as result,
   constructor function any_data_object( p_type_name varchar2 ) return self as result
);
/

create or replace type body any_data_object as

   overriding member procedure initialise( self in out nocopy any_data_object, p_data anydata ) is
      v_sql            varchar2(32767);
      v_builder        any_data_builder;
      v_tmp_obj        any_data_object;
      v_attribute      any_data;
      v_count          integer;
      begin
         v_builder := any_data_builder( p_data );

         self.type_info.set_type_name( v_builder.type_helper.get_type() );
         v_count := v_builder.type_helper.attributes_count;

         for i in 1 .. v_count loop
            self.add_element( v_builder.get_attribute(i) );
         end loop;

         v_tmp_obj := self;

         v_sql := '
            declare
               v_data      anydata := :p_data;
               v_obj       any_data_object := :p_obj;
            begin
               v_data.piecewise();';
         for i in 1 .. v_count loop
            v_attribute := self.get_element(i);
            v_sql := v_sql ||'
               declare
                  v_element '||v_attribute.get_type().get_type_def()||';
               begin
                  if v_data.'||v_attribute.get_type().getter_func_name()||'( v_element ) = DBMS_TYPES.NO_DATA then
                     raise NO_DATA_FOUND;
                  end if;
                  v_obj.data_values('||i||').data.initialise( anydata.'||v_attribute.get_type().converter_func_name()||'( v_element ) );
               end;
            ';
         end loop;
         v_sql := v_sql ||'
               :p_out_obj := v_obj;
            end;
         ';
         execute immediate v_sql using in p_data, in v_tmp_obj, out v_tmp_obj;
         self := v_tmp_obj;

      end;

   constructor function any_data_object return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_object, 'OBJECT' );
         data_values := any_data_tab();
         return;
      end;

   constructor function any_data_object( p_type_name varchar2 ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_object, p_type_name, 'OBJECT' );
         data_values := any_data_tab();
         return;
      end;

end;
/
