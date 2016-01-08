drop type anytype_info force;
/

create type anytype_info as object (
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
   count              number,
constructor function anytype_info ( pv_value anydata ) return self as result,
constructor function anytype_info ( pv_child_position pls_integer, pv_parent_type anytype ) return self as result,
constructor function anytype_info ( pv_type_code integer ) return self as result,
member procedure update_from_attribute_type( self in out nocopy anytype_info ),
member function get_type return varchar2,
member function get_typename return varchar2,
member function to_string return varchar2,
static function get_build_in_typename( p_typecode integer ) return varchar2
);
/

create or replace type body anytype_info is

   constructor function anytype_info ( pv_value anydata ) return self as result is
      begin
         self.type_code := pv_value.gettype( self.attribute_type );
         self.build_in_type_name := anytype_info.get_build_in_typename( self.type_code );
         update_from_attribute_type( );
         return;
      end;

   constructor function anytype_info ( pv_child_position pls_integer, pv_parent_type anytype ) return self as result is
      begin
         if pv_parent_type is not null
         then
            self.type_code := pv_parent_type.getAttrElemInfo(
               pv_child_position,
               self.prec,
               self.scale,
               self.len,
               self.csid,
               self.csfrm,
               self.attribute_type,
               self.attribute_name
            );
            self.build_in_type_name := anytype_info.get_build_in_typename( self.type_code );
            update_from_attribute_type( );
         end if;
         return;
      end;

   constructor function anytype_info ( pv_type_code integer ) return self as result is
      begin
         self.type_code := pv_type_code;
         self.build_in_type_name := anytype_info.get_build_in_typename( self.type_code );
         return;
      end;

member procedure update_from_attribute_type( self in out nocopy anytype_info ) is
      begin
         if self.attribute_type is not null
         then
            self.type_code := self.attribute_type.getinfo(
               self.prec,
               self.scale,
               self.len,
               self.csid,
               self.csfrm,
               self.schema_name,
               self.type_name,
               self.version,
               self.count );
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

member function to_string
      return varchar2 is
      begin
         return '
            attribute_name     => ' || self.attribute_name || '
            attribute_type     => ' || case when self.attribute_type is null
            then 'NULL'
                                       else 'NOT NULL' end || '
            prec               => ' || self.prec || '
            scale              => ' || self.scale || '
            len                => ' || self.len || '
            csid               => ' || self.csid || '
            csfrm              => ' || self.csfrm || '
            schema_name        => ' || self.schema_name || '
            type_name          => ' || self.type_name || '
            build_in_type_name => ' || self.build_in_type_name || '
            version            => ' || self.version || '
            type_code          => ' || self.type_code || '
            count              => ' || self.count;
      end;
static function get_build_in_typename( p_typecode integer )
      return varchar2 is
      v_result varchar2(30);
      begin
         case
            when p_typecode = dbms_types.typecode_date then v_result := 'DATE';
            when p_typecode = dbms_types.typecode_number then v_result := 'NUMBER';
            when p_typecode = dbms_types.typecode_raw then v_result := 'RAW';
            when p_typecode = dbms_types.typecode_char then v_result := 'CHAR';
            when p_typecode = dbms_types.typecode_varchar2 then v_result := 'VARCHAR2';
            when p_typecode = dbms_types.typecode_varchar then v_result := 'VARCHAR';
            when p_typecode = dbms_types.typecode_blob then v_result := 'BLOB';
            when p_typecode = dbms_types.typecode_bfile then v_result := 'BFILE';
            when p_typecode = dbms_types.typecode_clob then v_result := 'CLOB';
            when p_typecode = dbms_types.typecode_cfile then v_result := 'CFILE';
            when p_typecode = dbms_types.typecode_timestamp then v_result := 'TIMESTAMP';
            when p_typecode = dbms_types.typecode_timestamp_tz then v_result := 'TIMESTAMP WITH TIME ZONE';
            when p_typecode = dbms_types.typecode_timestamp_ltz then v_result := 'TIMESTAMP WITH LOCAL TIME ZONE';
            when p_typecode = dbms_types.typecode_interval_ym then v_result := 'INTERVAL YEAR TO MONTH';
            when p_typecode = dbms_types.typecode_interval_ds then v_result := 'INTERVAL DAY TO SECOND';
            when p_typecode = dbms_types.typecode_nchar then v_result := 'NCHAR';
            when p_typecode = dbms_types.typecode_nvarchar2 then v_result := 'NVARCHAR2';
            when p_typecode = dbms_types.typecode_nclob then v_result := 'NCLOB';
            when p_typecode = dbms_types.typecode_bfloat then v_result := 'BINARY_FLOAT';
            when p_typecode = dbms_types.typecode_bdouble then v_result := 'BINARY_DOUBLE';
            when p_typecode = dbms_types.typecode_object then v_result := 'OBJECT';
            when p_typecode = dbms_types.typecode_varray then v_result := 'VARRAY';
            when p_typecode = dbms_types.typecode_table then v_result := 'TABLE';
            when p_typecode = dbms_types.typecode_namedcollection then v_result := 'COLLECTION';
         end case;
         return v_result;
      end;
end;
/
