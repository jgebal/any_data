create or replace package anytype_helper_const as
   anydata_getter_place constant varchar2(30) := '{anydata_getter}';
   max_data_length      constant integer := 100;
end;
/
