require 'install'

describe 'Build reportable any data from ANYDATA' do

  def return_string_value(anydata)
    sql =  <<-SQL
      BEGIN
        :x := any_data_builder.build( #{anydata} ).to_string();
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'VARCHAR2', :in_out => 'OUT')
    cursor.exec
    cursor[":x"]
  end

  before(:all) do
    plsql.execute 'create or replace type test_col as table of number(5,3)'
    plsql.execute <<-SQL
      create or replace type test_obj as object(
        text varchar2(100),
        id number(22,11) )
    SQL
    plsql.execute 'create or replace type test_obj_col as table of test_obj'
    plsql.execute 'create or replace type test_col_col as table of test_col'
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
    plsql.execute 'drop type test_col_obj_col force'
    plsql.execute 'drop type test_parent_object force'
    plsql.execute 'drop type test_col_obj force'
    plsql.execute 'drop type test_col_col force'
    plsql.execute 'drop type test_obj_col force'
    plsql.execute 'drop type test_obj force'
    plsql.execute 'drop type test_col force'
  end

  context 'for build-in Oracle types' do

    [
      {type: 'BINARY_DOUBLE', in_val: 'ANYDATA.ConvertBDouble(123.456789)', expected: '1.23456789E+002'},
      {type: 'BINARY_FLOAT',  in_val: 'ANYDATA.ConvertBFloat(123.456)', expected: '1.23456001E+002'},
      {type: 'BLOB', in_val: "ANYDATA.ConvertBlob( utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%') )", expected: '1234%$#$%DRGSDFG$#%'},
      {type: 'CLOB', in_val: "ANYDATA.ConvertClob('clob value')", expected: 'clob value'},
      {type: 'CHAR', in_val: "ANYDATA.ConvertChar( 'A' )", expected: "'A'"},
      {type: 'DATE', in_val: "ANYDATA.ConvertDate( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ) )", expected: '2015-11-21 20:01:01'},
      {type: 'INTERVAL DAY TO SECOND', in_val: "ANYDATA.ConvertIntervalDS( INTERVAL '12 23:59:59.123456' DAY TO SECOND )", expected: '+000000012 23:59:59.123456000'},
      {type: 'INTERVAL YEAR TO MONTH', in_val: "ANYDATA.ConvertIntervalYM( INTERVAL '99-11' YEAR TO MONTH )", expected: '+000000099-11'},
      {type: 'NUMBER', in_val: 'ANYDATA.ConvertNumber( 3 )', expected: '3'},
      {type: 'VARCHAR', in_val: "ANYDATA.ConvertVarchar( 'Sample varchar' )", expected: "'Sample varchar'"},
      {type: 'VARCHAR2', in_val: "ANYDATA.ConvertVarchar2( 'Sample varchar2' )", expected: "'Sample varchar2'"},
    ].each do |test_case|
      it "reports a #{test_case[:type]} datatype" do
        expect(return_string_value test_case[:in_val] ).to eq test_case[:expected]
      end
    end
  end

  context 'for user defined object type' do

    it 'reports an object type' do
      test_object="test_obj( 'some ''characters', 1234567890.12345678901)"
      expected = "GENERIC_UTIL.TEST_OBJ(
   TEXT => 'some ''characters',
   ID => 1234567890.12345678901
)"
      expect(return_string_value "ANYDATA.ConvertObject( #{test_object} )" ).to eq expected
    end

    it 'reports on object within an object' do
      test_object="test_parent_object( 1234, test_obj( 'some characters', 1234567890.12345678901) )"
      expected = "GENERIC_UTIL.TEST_PARENT_OBJECT(
   SOME_ID => 1234,
   CHILD_OBJ => GENERIC_UTIL.TEST_OBJ(
      TEXT => 'some characters',
      ID => 1234567890.12345678901
   )
)"
      expect(return_string_value "ANYDATA.ConvertObject( #{test_object} )" ).to eq expected
    end

    it 'reports on collection within an object' do
      test_col_obj="test_col_obj( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ), 'some characters', test_col( 1, 2, 3.456, 7.8, 9 ), 1.23 )"
      expected = "GENERIC_UTIL.TEST_COL_OBJ(
   A_DATE => 2015-11-21 20:01:01,
   A_CHAR => 'some characters',
   A_COL => GENERIC_UTIL.TEST_COL(
      1,
      2,
      3.456,
      7.8,
      9
   ),
   A_NUM2 => 1.23
)"
      expect(return_string_value "ANYDATA.ConvertObject( #{test_col_obj} )" ).to eq expected
    end

  end

  context 'user defined collection types' do


    it 'reports on collection of primitives' do
      test_collection='test_col( 1, 2, 3.456, 7.8, 9 )'
      expected = 'GENERIC_UTIL.TEST_COL(
   1,
   2,
   3.456,
   7.8,
   9
)'
      expect(return_string_value "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected

    end

    it 'reports on collection of objects' do
      test_object="test_obj('test',1)"
      test_collection="test_obj_col( #{test_object},#{test_object} )"
      expected = "GENERIC_UTIL.TEST_OBJ_COL(
   GENERIC_UTIL.TEST_OBJ(
      TEXT => 'test',
      ID => 1
   ),
   GENERIC_UTIL.TEST_OBJ(
      TEXT => 'test',
      ID => 1
   )
)"
      expect(return_string_value "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected
    end

    it 'reports on collection of collections' do
      test_collection='test_col_col(test_col( 1, 2, 3.456, 7.8, 9 ), test_col( 4,5,6,7.89 ))'
      expected = 'GENERIC_UTIL.TEST_COL_COL(
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
      expect(return_string_value "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected
    end

    it 'reports on collection of objects with collections' do
      test_collection='test_col( 1, 2 )'
      test_col_obj="test_col_obj( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ), 'some characters', #{test_collection}, 1.23 )"
      test_col_obj_col="test_col_obj_col( #{test_col_obj}, #{test_col_obj} )"
      expected = "GENERIC_UTIL.TEST_COL_OBJ_COL(
   GENERIC_UTIL.TEST_COL_OBJ(
      A_DATE => 2015-11-21 20:01:01,
      A_CHAR => 'some characters',
      A_COL => GENERIC_UTIL.TEST_COL(
         1,
         2
      ),
      A_NUM2 => 1.23
   ),
   GENERIC_UTIL.TEST_COL_OBJ(
      A_DATE => 2015-11-21 20:01:01,
      A_CHAR => 'some characters',
      A_COL => GENERIC_UTIL.TEST_COL(
         1,
         2
      ),
      A_NUM2 => 1.23
   )
)"
      expect(return_string_value "ANYDATA.ConvertCollection( #{test_col_obj_col} )" ).to eq expected
    end

  end

end
