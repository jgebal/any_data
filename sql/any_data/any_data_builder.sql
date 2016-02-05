drop type any_data_builder force;
/

create or replace type any_data_builder as object(
   type_info any_type_mapper,
   raw_data  anydata,
   constructor function any_data_builder( p_data anydata ) return self as result,
   member function get_any_data return any_data,
   member function get_attribute( p_position integer ) return any_data_attribute,
   member function get_element( p_position integer ) return any_data
);
/

create or replace type body any_data_builder as

   constructor function any_data_builder( p_data anydata ) return self as result is
      begin
         raw_data  := p_data;
         type_info := any_type_mapper( raw_data );
         return;
      end;

   member function get_any_data return any_data is
      v_result any_data;
      begin
         v_result := any_data_mapper.get_by_typecode( type_info.type_code );
         v_result.initialise( raw_data );
         return v_result;
      end;

   member function get_attribute( p_position integer ) return any_data_attribute is
      begin
         return any_data_attribute(
            type_info.get_attribute_type( p_position ).attribute_name,
            get_element( p_position )
         );
      end;

   member function get_element( p_position integer ) return any_data is
      v_attribute_type any_type_mapper;
      v_data_element   any_data;
      begin
         v_attribute_type := type_info.get_attribute_type( p_position );

         v_data_element := any_data_mapper.get_by_typecode( v_attribute_type.type_code );
         v_data_element.type_info.set_type_info( v_attribute_type.get_typename(), v_attribute_type.get_type() );

         return v_data_element;
      end;
end;
/

