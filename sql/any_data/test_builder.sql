drop type test_number_object force;
drop type test_object force;
drop type test_object_2 force;
drop type a_tab force;
drop type a_var force;
create type simple_tab as table of number;
/
create type test_number_object as object(
   a_number number(38),
   b_number number(38)
);
/
create type test_object as object (
   val test_number_object
);
/
create type test_object_2 as object(
   a_value test_object
);
/
create or replace type a_tab as table of test_object_2;
/

declare
   z test_object_2;
   q a_tab := a_tab();
   a anydata;
   i integer;
begin
   z := test_object_2( test_object( test_number_object(1,2) ) );
   q := a_tab( z );
   a := anydata.convertCollection(q);
   declare
      v_data_1 a_tab;
      v_result any_data_collection;
   begin
      if a.getCollection( v_data_1 ) = DBMS_TYPES.NO_DATA then
         raise NO_DATA_FOUND;
      end if;
      v_result := any_data_collection( dbms_types.typecode_table );
      for i in 1 .. cardinality( v_data_1 ) loop
         declare
            v_data_2 test_object_2;
         begin
            v_data_2 := v_data_1( i );
            declare
               v_data_3 test_object;
            begin
               v_data_3 := v_data_2.a_value;
               declare
                  v_data_4 test_number_object;
               begin
                  v_data_4 := v_data_3.val;
                  declare
                     v_data_5 number;
                  begin
                     v_data_5 := v_data_4.a_number;
                  end;
                  declare
                     v_data_5 number;
                  begin
                     v_data_5 := v_data_4.b_number;
                  end;
               end;
            end;
         end;
      end loop;
   end;
end;
/
