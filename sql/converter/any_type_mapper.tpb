create or replace type body any_type_mapper is

   static function get_version return varchar2 is
      begin
         return '&&VERSION';
      end;

   member function get_attribute_type( p_child_position integer := null ) return any_type_mapper is
      begin
         return any_type_mapper( p_child_position, self.attribute_type );
      end;

   constructor function any_type_mapper( self in out nocopy any_type_mapper, p_value anydata ) return self as result is
      begin
         self.type_code := p_value.gettype( self.attribute_type );
         update_from_attribute_type( );
         return;
      end;

   constructor function any_type_mapper( self in out nocopy any_type_mapper, p_child_position pls_integer, p_parent_type anytype ) return self as result is
      begin
         if p_parent_type is not null
         then
            self.type_code := p_parent_type.getAttrElemInfo(
               p_child_position,
               self.prec,
               self.scale,
               self.len,
               self.csid,
               self.csfrm,
               self.attribute_type,
               self.attribute_name
            );
            update_from_attribute_type( );
         end if;
         return;
      end;

   constructor function any_type_mapper ( self in out nocopy any_type_mapper, p_type anytype ) return self as result is
      begin
         self.attribute_type := p_type;
         update_from_attribute_type( );
         return;
      end;

   member procedure update_from_attribute_type( self in out nocopy any_type_mapper ) is
      begin
         if self.attribute_type is not null
         then
            self.type_code := self.attribute_type.getInfo(
               self.prec,
               self.scale,
               self.len,
               self.csid,
               self.csfrm,
               self.schema_name,
               self.type_name,
               self.version,
               self.attributes_count );
         end if;
         --adjust precision and scale for number with NULL prec/scale
         if self.prec = 0 and self.scale = -127 then
            self.prec := null; self.scale := null;
         end if;
         --adjust length for nvarchar types
         len := len / case when type_code in ( dbms_types.typecode_nchar, dbms_types.typecode_nvarchar2 ) then 2 else 1 end;
      end;

   member function get_typename
      return varchar2 is
      begin
         return
         case
         when type_name is null then null
         when schema_name is null then type_name
         else schema_name || '.' || type_name
         end;
      end;

   member function get_type_unconstrained return varchar2 is
      begin
         return coalesce( get_typename, any_data_typecode_mapper.get_dbms_types_mapping( type_code ).max_type_declaration );
      end;

   member function get_type_declaration return varchar2 is

      function add_brackets( around_string varchar2 ) return varchar2 is
         begin return case when around_string != ',' then '(' || around_string || ')' end; end;

      function add_prec_scale_len( p_type in varchar2 ) return varchar2 is
         begin
            return
            replace(
               replace(
                  replace( replace( p_type, '{scale}', add_brackets( scale ) ), '{precision}', add_brackets( prec ) ),
                  '{precision_scale}', add_brackets( prec||','||scale ) ), '{length}', add_brackets( len ) );
         end;

      begin
         return coalesce( get_typename(), add_prec_scale_len( any_data_typecode_mapper.get_dbms_types_mapping( type_code ).type_declaration_template ) );
      end;

   member function is_attribute return boolean is
      begin
         return (attribute_name is not null);
      end;

   member function get_any_data_constructor( p_value_var_name varchar2 ) return varchar2 is
      begin
         return get_any_data_object_name()||'( '||type_code||', '''||get_typename()||''', '''||get_any_data_object_name()||''', '||p_value_var_name||' )';
      end;

   member function get_any_data_object_name return varchar2 is
      begin
         return any_data_typecode_mapper.get_dbms_types_mapping( type_code ).any_data_object_name;
      end;

   member function get_anydata_getter return varchar2 is
      begin
         return replace( replace( get_any_data_object_name(), 'any_data_' ), '_' );
      end;

   member function get_build_in_typename return varchar2 is
      begin
         return any_type_mapper.get_build_in_typename( type_code );
      end;

   static function get_build_in_typename( p_type_code integer) return varchar2 is
      begin
         return any_data_typecode_mapper.get_dbms_types_mapping( p_type_code ).build_in_type_name;
      end;
end;
/
