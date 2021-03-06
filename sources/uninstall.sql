--converters
drop package any_data_builder;
drop type any_type_mapper;

--final types
drop type any_data_timestamp_ltz;
drop type any_data_timestamp_tz;
drop type any_data_timestamp;
drop type any_data_date;
drop type any_data_interval_ym;
drop type any_data_interval_ds;

drop type any_data_blob;
drop type any_data_raw;

drop type any_data_clob;
drop type any_data_char;
drop type any_data_varchar;
drop type any_data_varchar2;

drop type any_data_bfloat;
drop type any_data_bdouble;
drop type any_data_number;

drop type any_data_object;
drop type any_data_collection;
drop type any_data_result_row;
drop type any_data_result_set;

--type families
drop type any_data_family_date;
drop type any_data_family_raw;
drop type any_data_family_string;
drop type any_data_family_numeric;
drop type any_data_family_compound;

--base type collection
drop type any_data_tab;

--base types
drop type any_data_attribute;
drop type any_data;

--helpers
drop package any_data_typecode_mapper;
drop package any_data_formatter;
drop package any_data_const;
drop type string_array;

drop table sql_type_code_mappings;
drop table dbms_type_code_mappings;

exit
