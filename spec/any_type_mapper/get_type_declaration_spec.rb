describe 'any_type_mapper' do

  describe 'get_type_declaration' do

    def get_type_declaration( object_constructor, field_no )
      sql = <<-SQL
      BEGIN
        :x := any_type_mapper( #{object_constructor} ).get_attribute_type( #{field_no} ).get_type_declaration( );
      END;
      SQL
      cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'VARCHAR2', :in_out => 'OUT')
      cursor.exec
      cursor[":x"]
    end

    before(:all) do
      plsql.execute <<-SQL
      create or replace type test_type_def as object(
         a number,
         b number(35),
         c number(4,3),
         d varchar2(3),
         e varchar(48),
         f blob,
         g clob,
         h timestamp(2),
         i interval day(2) to second(5),
         j interval year(7) to month,
         k timestamp(8) with time zone,
         l timestamp(4) with local time zone,
         m raw(1),
         n char(2),
         o nchar(3),
         p nvarchar2(2000),
         r binary_double,
         s binary_float,
         t date,
         constructor function test_type_def return self as result
      )
      SQL
      plsql.execute <<-SQL
      create or replace type body test_type_def is
         constructor function test_type_def return self as result is
            begin return; end;
      end;
      SQL
    end

    after(:all) do
      plsql.execute 'drop type test_type_def' rescue nil
    end

    [
      'NUMBER',
      'NUMBER(35,0)',
      'NUMBER(4,3)',
      'VARCHAR2(3)',
      'VARCHAR2(48)',
      'BLOB',
      'CLOB',
      'TIMESTAMP(2)',
      'INTERVAL DAY(2) TO SECOND(5)',
      'INTERVAL YEAR(7) TO MONTH',
      'TIMESTAMP(8) WITH TIME ZONE',
      'TIMESTAMP(4) WITH LOCAL TIME ZONE',
      'RAW(1)',
      'CHAR(2)',
      'NCHAR(3)',
      'NVARCHAR2(2000)',
      'BINARY_DOUBLE',
      'BINARY_FLOAT',
      'DATE',
    ].each_with_index do |expected_type, index|
      attribute_position = index+1
      it 'returns type declarations corresponding to the object type fields' do
        expect( get_type_declaration( 'anydata.convertObject( test_type_def() )', attribute_position ) ).to eq expected_type
      end

    end


  end

end
