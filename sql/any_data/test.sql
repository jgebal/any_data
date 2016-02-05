declare
   x test_number_object;
   y test_object;
   z test_object_2;
   a anydata;
   d any_data;
   v_loops integer := 1000;
begin
   dbms_profiler.START_PROFILER('any_data '||v_loops||' times');
   x := test_number_object(1,2);
   y := test_object(x);
   z := test_object_2(y);
   a := anydata.convertObject(z);
   for i in 1 .. v_loops loop
      d := ANY_DATA_BUILDER(a).get_any_data();
   end loop;
   dbms_output.put_line( d.to_string() );
   dbms_profiler.stop_PROFILER();
end;
/


declare
   x test_number_object;
   y test_object;
   z test_object_2;
   a anydata;
   d any_data;
begin
   x := test_number_object(1,2);
   y := test_object(x);
   z := test_object_2(y);
   a := anydata.convertObject(z);
   for i in 1 .. 10 loop
      d := ANY_DATA_BUILDER(a).get_any_data();
   end loop;
   dbms_output.put_line( d.to_string() );
end;
/


drop type test_number_object force;
drop type test_object force;
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


