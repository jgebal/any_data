--inspired by https://ellebaek.wordpress.com/2011/02/25/oracle-type-code-mappings/
create table dbms_type_code_mappings (
   dbms_types_type_code      int,
   any_data_object_name      varchar2(100),
   anydata_getter as( replace( replace( any_data_object_name, 'any_data_' ), '_' ) ),
   max_precision             int,
   max_scale                 int,
   max_length                int,
   type_declaration_template varchar2(100),
   build_in_type_name as ( regexp_replace( type_declaration_template, '\{[precision|scale|precision_scale|length]*\}', '' ) ),
   max_type_declaration as (
   replace(
      replace(
         replace(
            replace( type_declaration_template, '{precision}',nvl2( max_precision, '(' || max_precision || ')', null )),
            '{scale}',
            nvl2( max_scale, '(' || max_scale || ')', null )
         ),
         '{length}',
         nvl2( max_length, '(' || max_length || ')', null )
      ),
      '{precision_scale}',
      nvl2( max_precision||max_scale, '(' || max_precision||'.'||max_scale|| ')', null )
   )
   ),
   constraint dbms_type_code_mappings_pk primary key (dbms_types_type_code)
);
