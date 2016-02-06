require 'anydata_reporter'

describe 'get report from any data' do

  def exec_reporter(anydata)
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

    it 'reports a NUMBER datatype' do
      result = exec_reporter 'ANYDATA.ConvertNumber( 3 )'
      expect( result ).to eq '3'
    end

    it 'reports a VARCHAR2 datatype' do
      result = exec_reporter "ANYDATA.ConvertVarchar2( 'Sample varchar' )"
      expect( result ).to eq "v_varchar2(VARCHAR2) => 'Sample varchar'"
    end

    [
      {type: 'DATE', in_val: "ANYDATA.ConvertDate( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ) )", expected: 'MY_VARIABLE(DATE) => 2015-11-21 20:01:01'},
      {type: 'BINARY_DOUBLE', in_val: 'ANYDATA.ConvertBDouble(123.456789)', expected: 'MY_VARIABLE(BINARY_DOUBLE) => 1.23456789E+002'},
      {type: 'BINARY_FLOAT',  in_val: 'ANYDATA.ConvertBFloat(123.456)', expected: 'SOME_VARIABLE(BINARY_FLOAT) => 1.23456001E+002'},
      {type: 'BLOB', in_val: "ANYDATA.ConvertBlob( utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%') )", expected: 'MY_VARIABLE(BLOB) => 1234%$#$%DRGSDFG$#%'},
      {type: 'CHAR', in_val: "ANYDATA.ConvertChar( 'A' )", expected: "SOME_VARIABLE(CHAR) => 'A'"},
      {type: 'CLOB', in_val: "ANYDATA.ConvertClob('clob value')", expected: 'VAR(CLOB) => clob value'},
    ].each do |test_case|
      it "reports a #{test_case[:type]} datatype" do
        expect( exec_reporter test_case[:in_val] ).to eq test_case[:expected]
      end
    end
  end

  context 'for user defined object type' do

    it 'reports an object type' do
      test_object="test_obj( 'some characters', 1234567890.12345678901)"
      expected = "pv_obj(GENERIC_UTIL.TEST_OBJ) => {
  TEXT(VARCHAR2(100)) => 'some characters',
  ID(NUMBER(22,11)) => 1234567890.12345678901
}"
      expect( exec_reporter "ANYDATA.ConvertObject( #{test_object} )" ).to eq expected
    end

    it 'reports on object within an object' do
      test_object="test_obj( 'some characters', 1234567890.12345678901)"
      test_parent_object="test_parent_object( 1234, #{test_object} )"
      expected = "pv_obj(GENERIC_UTIL.TEST_PARENT_OBJECT) => {
  SOME_ID(NUMBER) => 1234,
  CHILD_OBJ(GENERIC_UTIL.TEST_OBJ) => {
    TEXT(VARCHAR2(100)) => 'some characters',
    ID(NUMBER(22,11)) => 1234567890.12345678901
  }
}"
      expect( exec_reporter "ANYDATA.ConvertObject( #{test_parent_object} )" ).to eq expected
    end

    it 'reports on collection within an object' do
      test_collection='test_col( 1, 2, 3.456, 7.8, 9 )'
      test_col_obj="test_col_obj( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ), 'some characters', #{test_collection}, 1.23 )"
      expected = "pv_obj(GENERIC_UTIL.TEST_COL_OBJ) => {
  A_DATE(DATE) => 2015-11-21 20:01:01,
  A_CHAR(VARCHAR2(1000)) => 'some characters',
  A_COL(GENERIC_UTIL.TEST_COL) => [
    (NUMBER(5,3)) => 1,
    (NUMBER(5,3)) => 2,
    (NUMBER(5,3)) => 3.456,
    (NUMBER(5,3)) => 7.8,
    (NUMBER(5,3)) => 9
  ],
  A_NUM2(NUMBER(3,2)) => 1.23
}"
      expect( exec_reporter "ANYDATA.ConvertObject( #{test_col_obj} )" ).to eq expected
    end

  end

  context 'user defined collection types' do


    it 'reports on collection of primitives' do
      test_collection='test_col( 1, 2, 3.456, 7.8, 9 )'
      expected = 'pv_col(GENERIC_UTIL.TEST_COL) => [
  (NUMBER(5,3)) => 1,
  (NUMBER(5,3)) => 2,
  (NUMBER(5,3)) => 3.456,
  (NUMBER(5,3)) => 7.8,
  (NUMBER(5,3)) => 9
]'
      expect( exec_reporter 'pv_col', "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected

    end

    it 'reports on collection of objects' do
      test_object="test_obj('test',1)"
      test_collection="test_obj_col( #{test_object},#{test_object} )"
      expected = "pv_col(GENERIC_UTIL.TEST_OBJ_COL) => [
  (GENERIC_UTIL.TEST_OBJ) => {
    TEXT(VARCHAR2(100)) => 'test',
    ID(NUMBER(22,11)) => 1
  },
  (GENERIC_UTIL.TEST_OBJ) => {
    TEXT(VARCHAR2(100)) => 'test',
    ID(NUMBER(22,11)) => 1
  }
]"
      expect( exec_reporter 'pv_col', "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected
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
      expect( exec_reporter "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected
    end

    it 'reports on collection of objects with collections' do
      test_collection='test_col( 1, 2 )'
      test_col_obj="test_col_obj( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ), 'some characters', #{test_collection}, 1.23 )"
      test_col_obj_col="test_col_obj_col( #{test_col_obj}, #{test_col_obj} )"
      expected = "pv_col(GENERIC_UTIL.TEST_COL_OBJ_COL) => [
  (GENERIC_UTIL.TEST_COL_OBJ) => {
    A_DATE(DATE) => 2015-11-21 20:01:01,
    A_CHAR(VARCHAR2(1000)) => 'some characters',
    A_COL(GENERIC_UTIL.TEST_COL) => [
      (NUMBER(5,3)) => 1,
      (NUMBER(5,3)) => 2
    ],
    A_NUM2(NUMBER(3,2)) => 1.23
  },
  (GENERIC_UTIL.TEST_COL_OBJ) => {
    A_DATE(DATE) => 2015-11-21 20:01:01,
    A_CHAR(VARCHAR2(1000)) => 'some characters',
    A_COL(GENERIC_UTIL.TEST_COL) => [
      (NUMBER(5,3)) => 1,
      (NUMBER(5,3)) => 2
    ],
    A_NUM2(NUMBER(3,2)) => 1.23
  }
]"
      expect( exec_reporter "ANYDATA.ConvertCollection( #{test_col_obj_col} )" ).to eq expected
    end

  end

  context 'suptypes' do
    context 'subtypes of object type' do

      it 'reports on subtype if super type variable with subtype value passed' do
        pending 'to be implemented'
        expect(1).to eq 0
      end


    end

    context 'collection of type with subtypes' do

      it 'reports on subtypes passed to collection' do
        pending 'to be implemented'
        expect(1).to eq 0
      end
    end
  end

end
