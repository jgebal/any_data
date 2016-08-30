create user generic_util identified by generic_util quota unlimited on USERS default tablespace USERS;
grant create session, create procedure, create type, create table, create sequence, create view to generic_util;

grant execute on sys.dbms_crypto to generic_util;

