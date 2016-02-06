declare
   v_input  anydata;
   v_sql    varchar2(32767);
   v_result any_data;
   procedure get_type_info( p_mapper any_type_mapper, p_level integer := 1) is
      begin
         dbms_output.put_line( lpad(' ',2*p_level)||p_mapper.attribute_name||' '||p_mapper.get_typename()||' '||p_mapper.attributes_count );
         if p_mapper.type_code = dbms_types.typecode_object then
            for i in 1 .. p_mapper.attributes_count loop
               get_type_info( p_mapper.get_attribute_type( i ), p_level + 1 );
            end loop;
         elsif p_mapper.type_code in ( dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection ) then
            get_type_info( p_mapper.get_attribute_type( 1 ), p_level + 1 );
         end if;
      end;

   function get_sql_for_object( p_child_sql varchar2, p_type_name varchar2, p_level integer, p_return_assignment varchar2, p_attribute_name varchar2 ) return varchar2 is
        v_return_assignment varchar2(1000);
      begin
         if p_attribute_name is not null then
            v_return_assignment := 'any_data_attribute( '''||p_attribute_name||''', v_out_' || p_level ||')';
         else
            v_return_assignment := 'v_out_' || p_level;
         end if;
         return 'declare
         v_out_'||p_level||' any_data := any_data_object( '''||p_type_name||''' );
      begin
         '||p_child_sql||replace( p_return_assignment, '{value}', v_return_assignment )||'
      end;
         ';
      end;
   function get_sql_for_scalar( p_return_assignment varchar2, p_any_data_type varchar2, p_attribute_name varchar2, p_data_breadcrumb varchar2 ) return varchar2 is
      begin
         return replace( p_return_assignment,
                         '{value}',
                         'any_data_attribute( '''||p_attribute_name||''', any_data_'||p_any_data_type||'( '||p_data_breadcrumb||' ) )' )||'
         ';
      end;

   function get_sql( p_mapper any_type_mapper, p_data_breadcrumb varchar2, p_level integer := 0, p_return_assignment varchar2 := ':p_out := {value};' ) return varchar2 is
      v_sql varchar2(32767);
      v_return_assignment varchar2(1000) := p_return_assignment;
      v_data_breadcrumb   varchar2(4000) := p_data_breadcrumb;
      begin
         if p_mapper.attribute_name is not null then
            v_return_assignment := 'v_out_'||p_level||'.add_element( {value} );';
            v_data_breadcrumb    :=  v_data_breadcrumb||'.'||p_mapper.attribute_name;
--          else
--             v_return_assignment := 'v_out_'||p_level||'.add_element( {value} );';
         end if;
         if p_mapper.type_code = dbms_types.typecode_object then
            for i in 1 .. p_mapper.attributes_count loop
               v_sql := v_sql || get_sql( p_mapper.get_attribute_type( i ), v_data_breadcrumb, p_level + 1, v_return_assignment );
            end loop;
            v_sql := get_sql_for_object( v_sql, p_mapper.get_typename(), p_level+1, v_return_assignment, p_mapper.attribute_name );
--            elsif p_mapper.type_code in ( dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection ) then
--               v_sql := get_sql( p_mapper.get_attribute_type( 1 ), p_level );
         else
            v_sql := get_sql_for_scalar( p_return_assignment, p_mapper.get_typename(), p_mapper.attribute_name, v_data_breadcrumb );
         end if;
         return v_sql;
      end;
begin
      v_input  := anydata.convertObject( test_object_2( test_object( test_number_object(1,2) ) ) );
   --   v_input  := anydata.convertCollection( a_tab( test_object_2( test_object( test_number_object(1,2) ) ) ) );
--   v_input  := anydata.convertCollection( a_tab( test_obj_2_bis( test_object( test_number_object(1,2) ) ,123 ) ) );
--   get_type_info( any_type_mapper(v_input) );
   v_sql := get_sql( any_type_mapper(v_input), 'v_data' );
   v_sql := '
   declare
      v_input anydata := :p_input;
      v_data  test_object_2;
   begin
      if v_input.getObject( v_data ) = DBMS_TYPES.NO_DATA then
         raise NO_DATA_FOUND;
      end if;
      '||v_sql||'
   end;';
   dbms_output.put_line( v_sql );
   execute immediate v_sql using in v_input, out v_result;
   dbms_output.put_line( v_result.to_string() );
end;
/

declare
   v_sql varchar2(32767);
   v_input  anydata := anydata.convertObject( test_object_2( test_object( test_number_object(1,2) ) ) );
   v_out    any_data;
begin
   v_sql := q'[
declare
   v_input  anydata := :p_in;
   v_data   test_object_2;
   v_out_1  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT_2' );
begin
   if v_input.getObject( v_data ) = DBMS_TYPES.NO_DATA then
      raise NO_DATA_FOUND;
   end if;
   declare
      v_out_2  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT' );
   begin
      --add object element to v_out_2
      declare
         v_out_3  any_data := any_data_object( 'GENERIC_UTIL.TEST_NUMBER_OBJECT' );
      begin
         --add scalar element
         v_out_3.add_element( any_data_attribute( 'A_NUMBER', any_data_number( v_data.a_value.val.a_number ) ) );
         --add scalar element
         v_out_3.add_element( any_data_attribute( 'B_NUMBER', any_data_number( v_data.a_value.val.b_number ) ) );

         v_out_2.add_element( any_data_attribute( 'VAL', v_out_3 ) );
      end;
      v_out_1.add_element( any_data_attribute( 'A_VALUE', v_out_2 ) );
   end;
   :p_out := v_out_1;
end;
   ]';

   execute immediate v_sql using in v_input, out v_out;
   dbms_output.put_line( v_out.to_string() );
end;
/

declare
   v_input  anydata := anydata.convertObject( test_object_2( test_object( test_number_object(1,2) ) ) );
   v_data   test_object_2;
   v_out_1  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT_2' );
begin
   if v_input.getObject( v_data ) = DBMS_TYPES.NO_DATA then
      raise NO_DATA_FOUND;
   end if;
   declare
      v_out_2  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT' );
   begin
      --add object element to v_out_2
      declare
         v_out_3  any_data := any_data_object( 'GENERIC_UTIL.TEST_NUMBER_OBJECT' );
      begin
         --add scalar element
         v_out_3.add_element( any_data_attribute( 'A_NUMBER', any_data_number( v_data.a_value.val.a_number ) ) );
         --add scalar element
         v_out_3.add_element( any_data_attribute( 'B_NUMBER', any_data_number( v_data.a_value.val.b_number ) ) );

         v_out_2.add_element( any_data_attribute( 'VAL', v_out_3 ) );
      end;
      v_out_1.add_element( any_data_attribute( 'A_VALUE', v_out_2 ) );
   end;
   dbms_output.put_line( v_out_1.to_string() );
end;
/

declare
   v_input  anydata := anydata.convertObject( test_object_2( test_object( test_number_object(1,2) ) ) );
   v_out_1  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT_2' );
   v_data test_object_2;
begin
   if v_input.getObject( v_data ) = DBMS_TYPES.NO_DATA then
      raise NO_DATA_FOUND;
   end if;
   --going throug internals of object 1
   declare
      v_out_2  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT' );  --
   begin

      --going through internals of object 2
      declare
         v_out_3  any_data := any_data_object( 'GENERIC_UTIL.TEST_NUMBER_OBJECT' );
      begin

         --going through internals of object 3
         begin
            v_out_3.add_element( any_data_attribute( 'A_NUMBER', any_data_number( v_data.a_value.val.a_number ) ) );  --scalar assignend to object 3 as element
         end;
         begin
            v_out_3.add_element( any_data_attribute( 'B_NUMBER', any_data_number( v_data.a_value.val.b_number ) ) );  --scalar assignend to object 3 as element
         end;
         --end going through internals of object 3

         v_out_2.add_element( any_data_attribute( 'VAL', v_out_3 ) );   --object 3 assignend to object 2 as element
      end;
      --end going through internals of object 2

      v_out_1.add_element( any_data_attribute( 'A_VALUE', v_out_2 ) ); --object 2 assignend to object 1 as element
   end;
   --end going through internals of object 1

   dbms_output.put_line( v_out_1.to_string() );
end;
/

declare
   v_input  anydata := anydata.convertObject( test_object_2( test_object( test_number_object(1,2) ) ) );
   v_out_1  any_data;
   v_data_1 test_object_2;
begin
   if v_input.getObject( v_data_1 ) = DBMS_TYPES.NO_DATA then
      raise NO_DATA_FOUND;
   end if;

   for i in 1 .. 10000 loop
      v_out_1 := any_data_object( 'GENERIC_UTIL.TEST_OBJECT_2' );
      declare
         v_out_2  any_data := any_data_object( 'GENERIC_UTIL.TEST_OBJECT' );
         v_data_2 test_object := v_data_1.a_value;
      begin
         --add object element to v_out_2
         declare
            v_out_3  any_data := any_data_object( 'GENERIC_UTIL.TEST_NUMBER_OBJECT' );
            v_data_3 test_number_object := v_data_2.val;
         begin
            --add scalar element
            v_out_3.add_element( any_data_attribute( 'A_NUMBER', any_data_number( v_data_3.a_number ) ) );
            --add scalar element
            v_out_3.add_element( any_data_attribute( 'B_NUMBER', any_data_number( v_data_3.b_number ) ) );

            v_out_2.add_element( any_data_attribute( 'VAL', v_out_3 ) );
         end;
         v_out_1.add_element( any_data_attribute( 'A_VALUE', v_out_2 ) );
      end;
   end loop;
   dbms_output.put_line( v_out_1.to_string() );
end;
/


declare
   v_input  anydata := anydata.convertNumber(1);
   v_result any_data_number;
   v_data   number;
begin
   if v_input.getNumber( v_data ) = DBMS_TYPES.NO_DATA then
      raise NO_DATA_FOUND;
   end if;
   v_result := any_data_number();
   v_result.data_value := v_data;
   dbms_output.put_line(v_result.to_string());
end;
/


declare
   v_input  anydata := anydata.convertObject( test_number_object(1,2) );
   v_result any_data_object;
   v_data   test_number_object;
begin
   if v_input.getObject( v_data ) = DBMS_TYPES.NO_DATA then
      raise NO_DATA_FOUND;
   end if;
   v_result := any_data_object( 'GENERIC_UTIL.TEST_NUMBER_OBJECT' );
   v_result.add_element( any_data_attribute( 'A_NUMBER', any_data_number( v_data.a_number ) ) );
   v_result.add_element( any_data_attribute( 'B_NUMBER', any_data_number( v_data.b_number ) ) );
   dbms_output.put_line( v_result.to_string() );
end;
/

declare
   x number := 1;
   a anydata;
   d any_data;
begin
   a := anydata.convertNumber(x);
   d := ANY_DATA_BUILDER(a).get_any_data();
   dbms_output.put_line( d.to_string() );
end;
/


-------------------------------------

drop type test_number_object force;
drop type test_object force;
drop type test_object_2 force;
drop type test_obj_2_bis force;
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
   VAL test_number_object
);
/
create type test_object_2 as object(
   A_VALUE test_object
) not final;
/
create or replace type a_tab as table of test_object_2;
/
create or replace type test_obj_2_bis under test_object_2(
   dummy number
);
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
