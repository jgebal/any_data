create or replace type any_type_mapper as object (
   attribute_name     varchar2(400),
   attribute_type     anytype,
   prec               number,
   scale              number,
   len                number,
   csid               number,
   csfrm              number,
   schema_name        varchar2(400),
   type_name          varchar2(400),
   build_in_typename  varchar2(400),
   version            varchar2(400),
   type_code          number,
   attributes_count   number,
   constructor function any_type_mapper ( self in out nocopy any_type_mapper, p_value anydata ) return self as result,
   constructor function any_type_mapper (  self in out nocopy any_type_mapper, p_child_position pls_integer, p_parent_type anytype ) return self as result,
   constructor function any_type_mapper ( self in out nocopy any_type_mapper, p_type anytype ) return self as result,
   static function get_version return varchar2,
   member function get_type_unconstrained return varchar2,
   member function get_type_declaration return varchar2,
   member function get_typename return varchar2,
   member function get_attribute_type( p_child_position integer := null ) return any_type_mapper,
   member procedure update_from_attribute_type( self in out nocopy any_type_mapper ),
   member function is_attribute return boolean,
   member function get_any_data_constructor( p_value_var_name varchar2 ) return varchar2,
   member function get_any_data_object_name return varchar2,
   member function get_anydata_getter return varchar2,
   member function get_build_in_typename return varchar2,
   static function get_build_in_typename( p_type_code integer) return varchar2
);
/

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
         if type_code in ( dbms_types.typecode_varchar2, dbms_types.typecode_char,
                           dbms_types.typecode_varchar, dbms_types.typecode_raw,
                           dbms_types.typecode_nvarchar2, dbms_types.typecode_nchar)
         and len is null then
            len := 32767;
         end if;
         self.build_in_typename := get_build_in_typename();
         --adjust precision and scale for number with NULL prec/scale
         if self.prec = 0 and self.scale = -127 then
            self.prec := null; self.scale := null;
         end if;
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
            self.build_in_typename := get_build_in_typename();
            --adjust precision and scale for number with NULL prec/scale
            if self.prec = 0 and self.scale = -127 then
               self.prec := null; self.scale := null;
            end if;
         end if;
         return;
      end;

   constructor function any_type_mapper ( self in out nocopy any_type_mapper, p_type anytype ) return self as result is
      begin
         self.attribute_type := p_type;
         update_from_attribute_type( );
         self.build_in_typename := get_build_in_typename();
         --adjust precision and scale for number with NULL prec/scale
         if self.prec = 0 and self.scale = -127 then
            self.prec := null; self.scale := null;
         end if;
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
      end;

   member function get_typename
      return varchar2 is
      begin
         return
         case
         when type_name is null
            then build_in_typename
         when schema_name is null
            then type_name
         else schema_name || '.' || type_name
         end;
      end;

   member function get_type_unconstrained return varchar2 is
      begin
         return
            case
               when type_code in (
                  dbms_types.typecode_raw,
                  dbms_types.typecode_char,
                  dbms_types.typecode_varchar2,
                  dbms_types.typecode_varchar,
                  dbms_types.typecode_nchar,
                  dbms_types.typecode_nvarchar2)
                  then get_typename( )||'(32767)'
               when type_code = dbms_types.typecode_timestamp then 'TIMESTAMP(9)'
               when type_code = dbms_types.typecode_timestamp_tz then 'TIMESTAMP(9) WITH TIME ZONE'
               when type_code = dbms_types.typecode_timestamp_ltz then 'TIMESTAMP(9) WITH LOCAL TIME ZONE'
               when type_code = dbms_types.typecode_interval_ym then 'INTERVAL YEAR(9) TO MONTH'
               when type_code = dbms_types.typecode_interval_ds then 'INTERVAL DAY(9) TO SECOND(9)'
               else get_typename( )
            end;
      end;

   member function get_type_declaration return varchar2 is
      function add_brackets( around_string varchar2 ) return varchar2 is
         begin return case when around_string is not null then '(' || around_string || ')' end; end;

      function get_precision_and_scale return varchar2 is
         begin
            return
               case
                  when prec is not null and scale is not null then add_brackets( prec||','||scale )
                  else coalesce( add_brackets( prec ), add_brackets( scale ) )
               end;
         end;
      function get_precision return varchar2 is begin return add_brackets( prec ); end;
      function get_scale return varchar2 is begin return add_brackets( scale ); end;
      function get_length return varchar2 is begin return add_brackets( len ); end;
      begin
         return
            case
               when type_code = dbms_types.typecode_number
               then get_typename()||get_precision_and_scale()
               when type_code in (
                  dbms_types.typecode_raw,
                  dbms_types.typecode_char,
                  dbms_types.typecode_varchar2,
                  dbms_types.typecode_varchar)
               then get_typename( )||get_length()
               when type_code in (
                  dbms_types.typecode_nchar,
                  dbms_types.typecode_nvarchar2)
               then get_typename( )||add_brackets( len/2 ) -- TODO this is a temporary workaround for ANYTYPE misbehavior
               when type_code = dbms_types.typecode_timestamp then 'TIMESTAMP'||get_scale()
               when type_code = dbms_types.typecode_timestamp_tz then 'TIMESTAMP'||get_scale()||' WITH TIME ZONE'
               when type_code = dbms_types.typecode_timestamp_ltz then 'TIMESTAMP'||get_scale()||' WITH LOCAL TIME ZONE'
               when type_code = dbms_types.typecode_interval_ym then 'INTERVAL YEAR'||get_precision()||' TO MONTH'
               when type_code = dbms_types.typecode_interval_ds then 'INTERVAL DAY'||get_precision()||' TO SECOND'||get_scale()
               else get_typename( )
            end;
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
      v_result varchar2(50);
      begin
         v_result :=
         case
         when type_code = dbms_types.typecode_bdouble then 'bdouble'
         when type_code = dbms_types.typecode_bfile then 'bfile' --not supported yet
         when type_code = dbms_types.typecode_bfloat then 'bfloat'
         when type_code = dbms_types.typecode_blob then 'blob'
         when type_code = dbms_types.typecode_cfile then 'cfile' --not supported yet
         when type_code = dbms_types.typecode_char then 'char'
         when type_code = dbms_types.typecode_clob then 'clob'
         when type_code in (dbms_types.typecode_varray, dbms_types.typecode_table, dbms_types.typecode_namedcollection) then 'collection'
         when type_code = dbms_types.typecode_date then 'date'
         when type_code = dbms_types.typecode_interval_ds then 'interval_ds'
         when type_code = dbms_types.typecode_interval_ym then 'interval_ym'
         when type_code = dbms_types.typecode_nchar then 'nchar'
         when type_code = dbms_types.typecode_nclob then 'nclob'
         when type_code in( dbms_types.typecode_number, 3 /*INTEGER*/, 246 /*SMALLINT*/) then 'number'
         when type_code = dbms_types.typecode_nvarchar2 then 'nvarchar2'
         when type_code = dbms_types.typecode_object then 'object'
         when type_code = dbms_types.typecode_raw then 'raw'
         when type_code = dbms_types.typecode_timestamp then 'timestamp'
         when type_code = dbms_types.typecode_timestamp_tz then 'timestamp_tz'
         when type_code = dbms_types.typecode_timestamp_ltz then 'timestamp_ltz'
         when type_code = dbms_types.typecode_varchar then 'varchar'
         when type_code = dbms_types.typecode_varchar2 then 'varchar2'
         end;
         if v_result is null then
            raise_application_error( -20000, 'Unknown typecode = '|| type_code );
         end if;
         return 'any_data_'||lower( v_result );
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
         return
            case p_type_code
               when dbms_types.typecode_date then 'DATE'
               when dbms_types.typecode_number then 'NUMBER'
               when dbms_types.typecode_raw then 'RAW'
               when dbms_types.typecode_char then 'CHAR'
               when dbms_types.typecode_varchar2 then 'VARCHAR2'
               when dbms_types.typecode_varchar then 'VARCHAR'
               when dbms_types.typecode_blob then 'BLOB'
               when dbms_types.typecode_bfile then 'BFILE'
               when dbms_types.typecode_clob then 'CLOB'
               when dbms_types.typecode_cfile then 'CFILE'
               when dbms_types.typecode_timestamp then 'TIMESTAMP'
               when dbms_types.typecode_timestamp_tz then 'TIMESTAMP WITH TIME ZONE'
               when dbms_types.typecode_timestamp_ltz then 'TIMESTAMP WITH LOCAL TIME ZONE'
               when dbms_types.typecode_interval_ym then 'INTERVAL YEAR TO MONTH'
               when dbms_types.typecode_interval_ds then 'INTERVAL DAY TO SECOND'
               when dbms_types.typecode_nchar then 'NCHAR'
               when dbms_types.typecode_nvarchar2 then 'NVARCHAR2'
               when dbms_types.typecode_nclob then 'NCLOB'
               when dbms_types.typecode_bfloat then 'BINARY_FLOAT'
               when dbms_types.typecode_bdouble then 'BINARY_DOUBLE'
               when dbms_types.typecode_object then 'OBJECT'
               when dbms_types.typecode_varray then 'VARRAY'
               when dbms_types.typecode_table then 'TABLE'
               when dbms_types.typecode_namedcollection then 'COLLECTION'
            end;
      end;
end;
/
