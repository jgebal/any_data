require 'anydata_reporter'

describe 'anydata reporter' do

  def exec_reporter(param_name, anydata_call)
    sql =  <<-SQL
      BEGIN
        :x := anydata_reporter.get_report( '#{param_name}', #{anydata_call});
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'VARCHAR2', :in_out => 'OUT')
    cursor.exec
    cursor[":x"]
  end

  context 'simple types' do

    it 'reports a NUMBER datatype' do
      result = exec_reporter 'NUMERIC_VAR', 'ANYDATA.ConvertNumber( 3 )'
      expect( result ).to eq 'NUMERIC_VAR(NUMBER) => 3'
    end

    it 'reports a VARCHAR2 datatype' do
      result = exec_reporter 'V_VARCHAR2', "ANYDATA.ConvertVarchar2( 'Sample varchar' )"
      expect( result ).to eq 'V_VARCHAR2(VARCHAR2) => "Sample varchar"'
    end

    [
      {type: 'DATE', in_name: 'MY_VARIABLE', in_val: "ANYDATA.ConvertDate( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ) )", expected: 'MY_VARIABLE(DATE) => 2015-11-21 20:01:01'},
      {type: 'BINARY_DOUBLE', in_name: 'MY_VARIABLE', in_val: 'ANYDATA.ConvertBDouble(123.456789)', expected: 'MY_VARIABLE(BINARY_DOUBLE) => 1.23456789E+002'},
      {type: 'BINARY_FLOAT', in_name: 'SOME_VARIABLE', in_val: 'ANYDATA.ConvertBFloat(123.456)', expected: 'SOME_VARIABLE(BINARY_FLOAT) => 1.23456001E+002'},
      {type: 'BLOB',in_name: 'MY_VARIABLE',   in_val: "ANYDATA.ConvertBlob( utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%') )", expected: 'MY_VARIABLE(BLOB) => "1234%$#$%DRGSDFG$#%"'},
      {type: 'CHAR',in_name: 'SOME_VARIABLE', in_val: "ANYDATA.ConvertChar('A')", expected: 'SOME_VARIABLE(CHAR) => "A"'},
      {type: 'CLOB',in_name: 'VAR', in_val: "ANYDATA.ConvertClob('clob value')", expected: 'VAR(CLOB) => "clob value"'},
    ].each do |test_case|
      it "reports a #{test_case[:type]} datatype" do
        expect( exec_reporter test_case[:in_name], test_case[:in_val] ).to eq test_case[:expected]
      end
    end
    #
    # it 'reports a INTERVAL YEAR TO MONTH datatype' do
    #   ANYDATA.ConvertIntervalYM
    # end
    # it 'reports a INTERVAL DAY TO SECOND datatype' do
    #   ANYDATA.ConvertIntervalDS
    # end
    # it 'reports a NCHAR datatype' do
    #   ANYDATA.ConvertNchar
    # end
    # it 'reports a NCLOB datatype' do
    #   ANYDATA.ConvertNClob
    # end
    # it 'reports a NVARCHAR2 datatype' do
    #   ANYDATA.ConvertNVarchar2
    # end
    # it 'reports a RAW datatype' do
    #   ANYDATA.ConvertRaw
    # end
    # it 'reports a TIMESTAMP datatype' do
    #   ANYDATA.ConvertTimestamp
    # end
    # it 'reports a TIMESTAMP WITH LOCAL TIME ZONE datatype' do
    #   ANYDATA.ConvertTimestampLTZ
    # end
    # it 'reports a TIMESTAMP WITH TIME ZONE datatype' do
    #   ANYDATA.ConvertTimestampTZ
    # end
    # it 'reports a VARCHAR datatype' do
    #   ANYDATA.ConvertVarchar
    # end
  end

  context 'object type' do

    before(:all) do
      plsql.execute <<-SQL
      CREATE OR REPLACE TYPE test_report_object AS OBJECT (
        a_date DATE,
        a_char VARCHAR2(1000),
        a_num1 NUMBER,
        a_num2 NUMBER(3,2)
      );
      SQL
    end

    after(:all) do
      plsql.execute "DROP TYPE test_report_object FORCE"
    end

    it 'reports an object type' do
      test_object="test_report_object( TO_DATE( '2015-11-21 20:01:01', 'YYYY-MM-DD HH24:MI:SS' ), 'some characters', 1234567890.12345678901, 1.23 )"
      expected = 'PV_OBJ(TEST_REPORT_OBJECT) => {
  A_DATE(DATE) => 2015-11-21 20:01:01,
  A_CHAR(VARCHAR2(1000)) => "some characters",
  A_NUM1(NUMBER) => 1234567890.12345678901,
  A_NUM2(NUMBER(3,2)) => 1.23
}'
      expect( exec_reporter 'pv_obj', "ANYDATA.ConvertObject( #{test_object} )" ).to eq expected
    end
  end

  context 'collection types' do

    before(:all) do
      plsql.execute 'CREATE OR REPLACE TYPE test_primitive_col AS TABLE OF NUMBER(5,3)'
      plsql.execute 'CREATE OR REPLACE TYPE test_obj AS OBJECT( text VARCHAR2(100), id NUMBER(20,0) )'
      plsql.execute 'CREATE OR REPLACE TYPE test_obj_col AS TABLE OF test_obj'
    end

    after(:all) do
      plsql.execute "DROP TYPE test_primitive_col FORCE"
      plsql.execute "DROP TYPE test_obj_col FORCE"
      plsql.execute "DROP TYPE test_obj FORCE"
    end

    it 'reports on collection of primitives' do
      test_collection="test_primitive_col( 1, 2, 3.456, 7.8, 9 )"
      expected = 'PV_COL(TEST_PRIMITIVE_COL) => [
  1,
  2,
  3.456,
  7.8,
  9
]'
      expect( exec_reporter 'pv_col', "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected

    end

    it 'reports on collection of objects' do
      test_object="test_obj('test',1)"
      test_collection="test_obj_col( #{test_object},#{test_object} )"
      expected = 'PV_COL(TEST_OBJ_COL) => [
  (TEST_OBJ) => {
    TEXT(VARCHAR2(100)) => "test",
    ID(NUMBER(20,0)) => 1
  },
  (TEST_OBJ) => {
    TEXT(VARCHAR2(100)) => "test",
    ID(NUMBER(20,0)) => 1
  }
]'
      expect( exec_reporter 'pv_col', "ANYDATA.ConvertCollection( #{test_collection} )" ).to eq expected

    end

  end

  context 'collection of objects type' do

  end

end
