drop type any_data_object force;
/

create or replace type any_data_object under any_data(
   data_values     any_data_attribute_tab,
   member procedure add_attribute( self in out nocopy any_data_object, p_attribute any_data_attribute ),
   member function get_attribute( p_position integer ) return any_data_attribute,
   member function get_attribute_count return integer,
   overriding member function to_string return varchar2,
   overriding member procedure initialise( self in out nocopy any_data_object, p_data anydata ),
   constructor function any_data_object return self as result
);
/

create or replace type body any_data_object as

   member function get_attribute_count return integer is
      begin
        return coalesce( cardinality( data_values ), 0 );
      end;

   member function get_attribute( p_position integer ) return any_data_attribute is
      begin
         return data_values( p_position );
      end;

   member procedure add_attribute( self in out nocopy any_data_object, p_attribute any_data_attribute ) is
      begin
         data_values.extend;
         data_values( data_values.last ) := p_attribute;
      end;

   overriding member function to_string return varchar2 is
      v_result varchar2(32767);
      values_count  integer := get_attribute_count();
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

   overriding member procedure initialise( self in out nocopy any_data_object, p_data anydata ) is
      v_sql            varchar2(32767);
      v_builder        any_data_builder;
      v_tmp_obj        any_data_object;
      v_attribute      any_data_attribute;
      v_count          integer;
      begin
         v_builder := any_data_builder( p_data );

         self.type_info.set_type_name( v_builder.type_info.get_type() );
         v_count := v_builder.type_info.attributes_count;

         for i in 1 .. v_count loop
            add_attribute( v_builder.get_attribute(i) );
         end loop;

         v_tmp_obj := self;

         v_sql := '
            declare
               v_data      anydata := :p_data;
               v_obj       any_data_object := :p_obj;
            begin
               v_data.piecewise();';
         for i in 1 .. v_count loop
            v_attribute := get_attribute(i);
            v_sql := v_sql ||'
               declare
                  v_element '||v_attribute.data.type_info.get_type_def()||';
               begin
                  if v_data.'||v_attribute.data.type_info.getter_func_name()||'( v_element ) = DBMS_TYPES.NO_DATA then
                     raise NO_DATA_FOUND;
                  end if;
                  v_obj.data_values('||i||').data.initialise( anydata.'||v_attribute.data.type_info.converter_func_name()||'( v_element ) );
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
         data_values := any_data_attribute_tab();
         return;
      end;

end;
/
