describe 'Build any_data object from anydata' do

  def return_string_value(anydata)
    sql = <<-SQL
      BEGIN
        :x := any_data_builder.build( #{anydata} ).to_string();
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'VARCHAR2', :in_out => 'OUT')
    cursor.exec
    cursor[":x"]
  end

  context 'build-in Oracle scalar types' do

    [
      { type: 'binary_double', in_val: 'anydata.ConvertBDouble(123.456789)', expected: '1.23456789E+002' },
      { type: 'binary_float', in_val: 'anydata.ConvertBFloat(123.456)', expected: '1.23456001E+002' },
      { type: 'blob', in_val: "anydata.ConvertBlob( utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%') )", expected: "'1234%$#$%DRGSDFG$#%'" },
      { type: 'raw',  in_val: "anydata.ConvertRaw( utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%') )", expected: "'1234%$#$%DRGSDFG$#%'" },
      { type: 'clob', in_val: "anydata.ConvertClob('clob ''value')", expected: "'clob ''value'" },
      { type: 'char', in_val: "anydata.ConvertChar( 'A' )", expected: "'A'" },
      { type: 'date', in_val: "anydata.ConvertDate( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ) )", expected: "to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' )" },
      { type: 'integer', in_val: 'anydata.ConvertNumber( CAST(1 AS INTEGER) )', expected: '1' },
      { type: 'interval day to second',
        in_val: "anydata.ConvertIntervalDS( interval '123456789 23:59:59.123456789' day to second )",
        expected: "interval '+123456789 23:59:59.123456789' day to second" },
      { type: 'interval year to month',
        in_val: "anydata.ConvertIntervalYM( interval '123456789-11' year to month )",
        expected: "interval '+123456789-11' year to month" },
      { type: 'number', in_val: 'anydata.ConvertNumber( 3 )', expected: '3' },
      { type: 'varchar', in_val: "anydata.ConvertVarchar( 'Sample varchar' )", expected: "'Sample varchar'" },
      { type: 'varchar2', in_val: "anydata.ConvertVarchar2( 'Sample varchar2' )", expected: "'Sample varchar2'" },
      { type: 'timestamp',
        in_val: "anydata.ConvertTimestamp( to_timestamp( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' ) )",
        expected: "to_timestamp( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' )"},
      { type: 'timestamp with time zone',
        in_val: "anydata.ConvertTimestampTZ( to_timestamp_tz( '2015-11-21 20:01:01.123456789 -04:00', 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' ) )",
        expected: "to_timestamp_tz( '2015-11-21 20:01:01.123456789 -04:00', 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' )"},
      { type: 'timestamp with local time zone',
        in_val: "anydata.ConvertTimestampLTZ( to_timestamp( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' ) )",
        expected: "to_timestamp( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' )"},
    ].each do |test_case|

      it "converts a #{test_case[:type]} into a string representation" do
        expect(return_string_value test_case[:in_val]).to eq test_case[:expected]
      end

    end

  end

  context 'complex types' do

    before(:all) do
      plsql.execute 'create or replace type test_col as table of number(5,3)'
      plsql.execute <<-SQL
      create or replace type datatype_obj as object(
      a01 binary_double,
      a02 binary_float,
      a03 blob,
      a04 clob,
      a05 char(1),
      a06 date,
      a07 integer,
      a08 interval day(9) to second(9),
      a09 interval year(9) to month,
      a10 number,
      a11 varchar(32767),
      a12 varchar2(32767),
      a13 character varying(30) ,
      a14 int,
      a15 smallint,
      a16 raw(32767),
      a17 timestamp(9),
      a18 timestamp(9) with time zone,
      a19 timestamp(9) with local time zone
      )
      SQL
      plsql.execute <<-SQL
      create or replace type test_obj as object(
        text varchar2(100),
        id number(22,11)
      ) not final
      SQL
      plsql.execute <<-SQL
      create or replace type test_under_obj under test_obj(
        description varchar2(100)
      ) not final
      SQL
      plsql.execute <<-SQL
      create or replace type test_obj_col as table of test_obj
      SQL
      plsql.execute <<-SQL
       create or replace type test_col_col as table of test_col
      SQL
      plsql.execute <<-SQL
      create or replace type test_col_obj as object (
        a_date date,
        a_char varchar2(1000),
        a_col  test_col,
        a_num2 number(3,2)
      );
      SQL
      plsql.execute <<-SQL
      create or replace type test_parent_object as object (
        some_id  number,
        child_obj test_obj
      );
      SQL
      plsql.execute 'create or replace type test_col_obj_col as table of test_col_obj'

    end

    after(:all) do

      plsql.execute 'drop type test_col_obj_col force' rescue nil
      plsql.execute 'drop type test_parent_object force' rescue nil
      plsql.execute 'drop type test_col_obj force' rescue nil
      plsql.execute 'drop type test_col_col force' rescue nil
      plsql.execute 'drop type test_obj_col force' rescue nil
      plsql.execute 'drop type test_col force' rescue nil
      plsql.execute 'drop type test_under_obj force' rescue nil
      plsql.execute 'drop type test_obj force' rescue nil
      plsql.execute 'drop type datatype_obj force' rescue nil

    end

    context 'user defined object type' do

      it 'converts an object into string representation' do
        test_object="generic_util.datatype_obj(
   a01 => 123.456789,
   a02 => 123.456,
   a03 => utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%'),
   a04 => 'clob value',
   a05 => 'Y',
   a06 => to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' ),
   a07 => 1,
   a08 => interval '123456789 23:59:59.123456789' day to second,
   a09 => interval '123456789-11' year to month,
   a10 => 3.1234567890123456789012345678901234567,
   a11 => 'Sample varchar',
   a12 => 'Sample varchar2',
   a13 => 'Sample character varying',
   a14 => 123456789,
   a15 => 123456789,
   a16 => utl_raw.cast_to_raw('ab'),
   a17 => to_timestamp   ( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' ),
   a18 => to_timestamp_tz( '2015-11-21 20:01:01.123456789 -04:00', 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' ),
   a19 => to_timestamp   ( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' )
)"
        expected   = "GENERIC_UTIL.DATATYPE_OBJ(
   a01 => 1.23456789E+002,
   a02 => 1.23456001E+002,
   a03 => '1234%$#$%DRGSDFG$#%',
   a04 => 'clob value',
   a05 => 'Y',
   a06 => to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' ),
   a07 => 1,
   a08 => interval '+123456789 23:59:59.123456789' day to second,
   a09 => interval '+123456789-11' year to month,
   a10 => 3.1234567890123456789012345678901234567,
   a11 => 'Sample varchar',
   a12 => 'Sample varchar2',
   a13 => 'Sample character varying',
   a14 => 123456789,
   a15 => 123456789,
   a16 => 'ab',
   a17 => to_timestamp( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' ),
   a18 => to_timestamp_tz( '2015-11-21 20:01:01.123456789 -04:00', 'yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm' ),
   a19 => to_timestamp( '2015-11-21 20:01:01.123456789', 'yyyy-mm-dd hh24:mi:ssxff9' )
)"
        expect(return_string_value "anydata.ConvertObject( #{test_object} )").to eq expected
      end

      it 'converts nested object into string representation' do
        test_object="test_parent_object( 1234, test_obj( 'some characters', 1234567890.12345678901) )"
        expected   = "GENERIC_UTIL.TEST_PARENT_OBJECT(
some_id => 1234, child_obj => GENERIC_UTIL.TEST_OBJ(
text => 'some characters',
id => 1234567890.12345678901
   )
)"
        expect(return_string_value "anydata.ConvertObject( #{test_object} )").to eq expected
      end

      it 'converts an object containing a collection into string representation' do
        test_col_obj="test_col_obj( to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' ), 'some characters', test_col( 1, 2, 3.456, 7.8, 9 ), 1.23 )"
        expected    = "GENERIC_UTIL.TEST_COL_OBJ(
   a_date => to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' ),
   a_char => 'some characters',
   a_col => GENERIC_UTIL.TEST_COL(
      1,
      2,
      3.456,
      7.8,
      9
   ),
   a_num2 => 1.23
)"
        expect(return_string_value "anydata.ConvertObject( #{test_col_obj} )").to eq expected
      end

    end

    context 'defined collection types' do


      it 'converts collection of primitives into string representation' do
        test_collection='test_col( 1, 2, 3.456, 7.8, 9 )'
        expected       = 'GENERIC_UTIL.TEST_COL(
   1,
   2,
   3.456,
   7.8,
   9
)'
        expect(return_string_value "anydata.ConvertCollection( #{test_collection} )").to eq expected

      end

      it 'converts collection of objects into string representation' do
        test_object    ="test_obj('test',1)"
        test_collection="test_obj_col( #{test_object},#{test_object} )"
        expected       = "GENERIC_UTIL.TEST_OBJ_COL(
   GENERIC_UTIL.TEST_OBJ(
      text => 'test',
      id => 1
   ),
   GENERIC_UTIL.TEST_OBJ(
      text => 'test',
      id => 1
   )
)"
        expect(return_string_value "anydata.ConvertCollection( #{test_collection} )").to eq expected
      end

      it 'converts collection of collections into string representation' do
        test_collection='test_col_col(test_col( 1, 2, 3.456, 7.8, 9 ), test_col( 4,5,6,7.89 ))'
        expected       = 'GENERIC_UTIL.TEST_COL_COL(
   GENERIC_UTIL.TEST_COL(
      1,
      2,
      3.456,
      7.8,
      9
   ),
   GENERIC_UTIL.TEST_COL(
      4,
      5,
      6,
      7.89
   )
)'
        expect(return_string_value "anydata.ConvertCollection( #{test_collection} )").to eq expected
      end

      it 'converts collection of objects with collections into string representation' do
        test_collection ='test_col( 1, 2 )'
        test_col_obj    ="test_col_obj( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ), 'some characters', #{test_collection}, 1.23 )"
        test_col_obj_col="test_col_obj_col( #{test_col_obj}, #{test_col_obj} )"
        expected        = "GENERIC_UTIL.TEST_COL_OBJ_COL(
   GENERIC_UTIL.TEST_COL_OBJ(
      a_date => to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' ),
      a_char => 'some characters',
      a_col => GENERIC_UTIL.TEST_COL(
         1,
         2
      ),
      a_num2 => 1.23
   ),
   GENERIC_UTIL.TEST_COL_OBJ(
      a_date => to_date( '2015-11-21 20:01:01', 'yyyy-mm-dd hh24:mi:ss' ),
      a_char => 'some characters',
      a_col => GENERIC_UTIL.TEST_COL(
         1,
         2
      ),
      a_num2 => 1.23
   )
)"
        expect(return_string_value "anydata.ConvertCollection( #{test_col_obj_col} )").to eq expected
      end

    end

    context 'sub-typed objects' do

      it 'converts collection of super-type containing sub-types into string representation' do
        test_object    ="test_obj('test',1)"
        test_sub_object="test_under_obj('test',1,'description')"
        test_collection="test_obj_col( #{test_object},#{test_sub_object} )"
        expected       = "GENERIC_UTIL.TEST_OBJ_COL(
   GENERIC_UTIL.TEST_OBJ(
      text => 'test',
      id => 1
   ),
   GENERIC_UTIL.TEST_UNDER_OBJ(
      text => 'test',
      id => 1,
      description => 'description'
   )
)"
        expect(return_string_value "anydata.ConvertCollection( #{test_collection} )").to eq expected
      end

      it 'converts sub-typed object within an object' do
        test_object="test_parent_object( 1234, test_under_obj( 'some characters', 1234567890.12345678901, 'description') )"
        expected   = "GENERIC_UTIL.TEST_PARENT_OBJECT(
   some_id => 1234,
   child_obj => GENERIC_UTIL.TEST_UNDER_OBJ(
      text => 'some characters',
      id => 1234567890.12345678901,
      description => 'description'
   )
)"
        expect(return_string_value "anydata.ConvertObject( #{test_object} )").to eq expected
      end

    end

  end

end
