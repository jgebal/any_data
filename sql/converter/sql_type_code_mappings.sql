--inspired by https://ellebaek.wordpress.com/2011/02/25/oracle-type-code-mappings/
create table sql_type_code_mappings (
   dbms_sql_typecode         int,
   dbms_types_type_code      int,
   constraint sql_type_code_mappings_pk primary key (dbms_sql_typecode),
   constraint sql_type_code_mappings_fk1 foreign key (dbms_types_type_code) references dbms_type_code_mappings(dbms_types_type_code)
);
