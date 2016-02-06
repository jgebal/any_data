create type any_type_mapper as object (
   attribute_name     varchar2(400),
   attribute_type     anytype,
   prec               number,
   scale              number,
   len                number,
   csid               number,
   csfrm              number,
   schema_name        varchar2(400),
   type_name          varchar2(400),
   build_in_type_name varchar2(400),
   version            varchar2(400),
   type_code          number,
   attributes_count   number,
   constructor function any_type_mapper ( p_value anydata ) return self as result,
   constructor function any_type_mapper ( p_child_position pls_integer, p_parent_type anytype ) return self as result,
   member function get_type return varchar2,
   member function get_typename return varchar2,
   member function get_attribute_type( p_child_position pls_integer ) return any_type_mapper,
   member procedure update_from_attribute_type( self in out nocopy any_type_mapper ),
   member function is_attribute return boolean,
   member function get_any_data_object_name return varchar2,
   member function get_anydata_getter return varchar2,
   member function get_build_in_typename return varchar2
);
/

create or replace type body any_type_mapper is

   member function get_attribute_type( p_child_position pls_integer ) return any_type_mapper is
      begin
         return any_type_mapper( p_child_position, self.attribute_type );
      end;

   constructor function any_type_mapper ( p_value anydata ) return self as result is
      begin
         self.type_code := p_value.gettype( self.attribute_type );
         self.build_in_type_name := get_build_in_typename();
         update_from_attribute_type( );
         if type_code in ( dbms_types.typecode_varchar2, dbms_types.typecode_char,
                           dbms_types.typecode_varchar, dbms_types.typecode_raw,
                           dbms_types.typecode_nvarchar2, dbms_types.typecode_nchar)
         and len is null then
            len := 32767;
         end if;
                           return;
      end;

   constructor function any_type_mapper ( p_child_position pls_integer, p_parent_type anytype ) return self as result is
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
            self.build_in_type_name := get_build_in_typename();
            update_from_attribute_type( );
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
            then build_in_type_name
         when schema_name is null
            then type_name
         else schema_name || '.' || type_name
         end;
      end;

   member function get_type
      return varchar2 is
      begin
         return get_typename( )
                || case
                   when prec is not null and not ( prec = 0 and NVL( scale, 0 ) = -127 )
                      then
                         '(' || prec || case when scale is not null
                            then ',' || scale end || ')'
                   when len is not null
                      then
                         '(' || len || ')'
                   end;
      end;

   member function is_attribute return boolean is
      begin
         return (attribute_name is not null);
      end;
   member function get_any_data_object_name return varchar2 is
      begin
         return 'any_data_'||lower( get_anydata_getter() );
      end;
   member function get_anydata_getter return varchar2 is
      begin
         return
         case
            when type_code = dbms_types.typecode_date then 'Date'
            when type_code = dbms_types.typecode_number then 'Number'
            when type_code = dbms_types.typecode_raw then 'Raw'
            when type_code = dbms_types.typecode_char then 'Char'
            when type_code = dbms_types.typecode_varchar2 then 'Varchar2'
            when type_code = dbms_types.typecode_varchar then 'Varchar'
            when type_code = dbms_types.typecode_blob then 'Blob'
            when type_code = dbms_types.typecode_bfile then 'Bfile'
            when type_code = dbms_types.typecode_clob then 'Clob'
            when type_code = dbms_types.typecode_cfile then 'Cfile'
            when type_code = dbms_types.typecode_timestamp then 'Timestamp'
            when type_code = dbms_types.typecode_timestamp_tz then 'TimestampTZ'
            when type_code = dbms_types.typecode_timestamp_ltz then 'TimestampLTZ'
            when type_code = dbms_types.typecode_interval_ym then 'IntervalYM'
            when type_code = dbms_types.typecode_interval_ds then 'IntervalDS'
            when type_code = dbms_types.typecode_nchar then 'Nchar'
            when type_code = dbms_types.typecode_nvarchar2 then 'Nvarchar2'
            when type_code = dbms_types.typecode_nclob then 'Nclob'
            when type_code = dbms_types.typecode_bfloat then 'BFloat'
            when type_code = dbms_types.typecode_bdouble then 'BDouble'
            when type_code = dbms_types.typecode_object then 'Object'
            when type_code = dbms_types.typecode_varray then 'Collection'
            when type_code = dbms_types.typecode_table then 'Collection'
            when type_code = dbms_types.typecode_namedcollection then 'Collection'
         end;
      end;
   member function get_build_in_typename return varchar2 is
      begin
         return
         case
            when type_code = dbms_types.typecode_date then 'DATE'
            when type_code = dbms_types.typecode_number then 'NUMBER'
            when type_code = dbms_types.typecode_raw then 'RAW'
            when type_code = dbms_types.typecode_char then 'CHAR'
            when type_code = dbms_types.typecode_varchar2 then 'VARCHAR2'
            when type_code = dbms_types.typecode_varchar then 'VARCHAR'
            when type_code = dbms_types.typecode_blob then 'BLOB'
            when type_code = dbms_types.typecode_bfile then 'BFILE'
            when type_code = dbms_types.typecode_clob then 'CLOB'
            when type_code = dbms_types.typecode_cfile then 'CFILE'
            when type_code = dbms_types.typecode_timestamp then 'TIMESTAMP'
            when type_code = dbms_types.typecode_timestamp_tz then 'TIMESTAMP WITH TIME ZONE'
            when type_code = dbms_types.typecode_timestamp_ltz then 'TIMESTAMP WITH LOCAL TIME ZONE'
            when type_code = dbms_types.typecode_interval_ym then 'INTERVAL YEAR TO MONTH'
            when type_code = dbms_types.typecode_interval_ds then 'INTERVAL DAY TO SECOND'
            when type_code = dbms_types.typecode_nchar then 'NCHAR'
            when type_code = dbms_types.typecode_nvarchar2 then 'NVARCHAR2'
            when type_code = dbms_types.typecode_nclob then 'NCLOB'
            when type_code = dbms_types.typecode_bfloat then 'BINARY_FLOAT'
            when type_code = dbms_types.typecode_bdouble then 'BINARY_DOUBLE'
            when type_code = dbms_types.typecode_object then 'OBJECT'
            when type_code = dbms_types.typecode_varray then 'VARRAY'
            when type_code = dbms_types.typecode_table then 'TABLE'
            when type_code = dbms_types.typecode_namedcollection then 'COLLECTION'
         end;
      end;
end;
/
