drop type anytype_info force;
/

create type anytype_info as object (
   attribute_name varchar2(400),
   attribute_type anytype,
   prec           integer,
   scale          integer,
   len            integer,
   csid           integer,
   csfrm          integer,
   schema_name    varchar2(400),
   type_name      varchar2(400),
   version        varchar2(400),
   type_code      integer,
   count          integer,
constructor function anytype_info ( pv_value anydata ) return self as result,
constructor function anytype_info ( pv_child_position pls_integer, pv_parent_type anytype ) return self as result,
member function get_child_type_info( pv_child_position pls_integer )
      return anytype_info,
member procedure update_from_attribute_type( self in out nocopy anytype_info ),
member function get_report
      return varchar2,
member function get_type
      return varchar2,
member function get_typename
      return varchar2,
member function to_string
      return varchar2
);
/

create type body anytype_info is
member procedure update_from_attribute_type( self in out nocopy anytype_info ) is
      begin
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
      end;

   constructor function anytype_info ( pv_value anydata ) return self as result is
      begin
         self.type_code := pv_value.gettype( self.attribute_type );
         if self.attribute_type is not null then
            self.update_from_attribute_type( );
         end if;
         return;
      end;

   constructor function anytype_info ( pv_child_position pls_integer, pv_parent_type anytype ) return self as result is
      begin
         if pv_parent_type is not null then
            SELF.type_code := pv_parent_type.getAttrElemInfo(
               pv_child_position,
               SELF.prec,
               SELF.scale,
               SELF.len,
               SELF.csid,
               SELF.csfrm,
               SELF.attribute_type,
               SELF.attribute_name
            );
            SELF.update_from_attribute_type( );
         end if;
         return;
      end;

member function get_child_type_info( pv_child_position pls_integer )
      return anytype_info is
      begin
         return anytype_info( pv_child_position, self.attribute_type );
      end;

member function get_typename
      return varchar2 is
      begin
         return case when schema_name is null
            then type_name
                else schema_name || '.' || type_name end;
      end;
member function get_report
      return varchar2 is
      begin
         return attribute_name || '(' || get_type( ) || ')';
      end;
member function get_type
      return varchar2 is
      begin
         return type_name;
--         return get_typename( )
--                 || case
--                    when prec is not null and not ( prec = 0 and NVL( scale, 0 ) = -127 )
--                       then
--                          '(' || prec || case when scale is not null
--                             then ',' || scale end || ')'
--                    when len is not null
--                       then
--                          '(' || len || ')'
--                    end;
      end;


member function to_string
      return varchar2 is
      begin
         return 'attribute_name=> ' || SELF.attribute_name || '
attribute_type => ' || case when SELF.attribute_type is null
            then 'NULL'
                       else 'NOT NULL' end || '
prec          => ' || SELF.prec || '
scale         => ' || SELF.scale || '
len           => ' || SELF.len || '
csid          => ' || SELF.csid || '
csfrm         => ' || SELF.csfrm || '
schema_name   => ' || SELF.schema_name || '
type_name     => ' || SELF.type_name || '
version       => ' || SELF.version || '
type_code     => ' || SELF.type_code || '
count         => ' || SELF.count;
      end;
   end;
/
