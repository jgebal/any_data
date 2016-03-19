
shared_context 'compare' do

  def compare(type, value, other_type, other_value)
    sql = <<-SQL
      BEGIN
        :x := #{type}( #{value} ).compare( #{other_type}( #{other_value} ) );
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'NUMBER', :in_out => 'OUT')
    cursor.exec
    result = cursor[":x"]
    cursor.close
    result
  end

end


shared_examples 'any data comparable types' do |type, value, other_type, other_value |

  value, bigger_value = value<other_value ? [value, other_value] : [other_value, value]
  include_context 'compare'

  context 'non null values comparison' do

    it 'returns 0 if both hold equal values' do
      expect(compare(type, value, other_type, value)).to eq 0
    end

    it 'returns -1 if self value is bigger' do
      expect(compare(type, value, other_type, bigger_value)).to eq -1
    end

    it 'returns 1 if compared value is bigger' do
      expect(compare(other_type, bigger_value, type, value)).to eq 1
   end

  end

end

shared_examples 'any data null comparison' do |type, value|

  include_context 'compare'

  context 'NULL values comparison' do

    null_value='NULL'

    it "returns NULL if self holds #{null_value} value" do
      expect(compare(type, null_value, type, value)).to be_nil
    end

    it "returns NULL if compared holds #{null_value} value" do
      expect(compare(type, value, type, null_value)).to be_nil
    end

    it "returns 0 if both holds #{null_value} value" do
      expect(compare(type, null_value, type, null_value)).to eq 0
    end

  end

end


describe 'any data compare' do

  include_context 'compare'

  context 'identical scalar types' do
    [
      {type_name: 'any_data_bdouble',       other_data_value: 987.654321,                            data_value: 123.456789 },
      {type_name: 'any_data_bfloat',        other_data_value: 521.321,                               data_value: 123.125 },
      {type_name: 'any_data_number',        other_data_value: 6,                                     data_value: 3 },
      {type_name: 'any_data_blob',          other_data_value: "utl_raw.cast_to_raw('324$#%')",       data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
      {type_name: 'any_data_raw',           other_data_value: "utl_raw.cast_to_raw('324$#%')",       data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
      {type_name: 'any_data_clob',          other_data_value: "'Different value'||'#{('a'*32767)}'", data_value: "'Clob value'||'#{('a'*32767)}'"},
      {type_name: 'any_data_char',          other_data_value: "'B'",                                 data_value: "'A'" },
      {type_name: 'any_data_varchar',       other_data_value: "'Other varchar'",                     data_value: "'A varchar'" },
      {type_name: 'any_data_varchar2',      other_data_value: "'Other varchar2'",                    data_value: "'A varchar2'" },
      {type_name: 'any_data_date',          other_data_value: "to_date('2016-02-29','yyyy-mm-dd')",  data_value: "to_date('2016-02-25','yyyy-mm-dd')" },
      {type_name: 'any_data_timestamp',
       other_data_value: "to_timestamp('2016-02-29 23:59:59.123456789','yyyy-mm-dd hh24:mi:ssxff9')",
       data_value: "to_timestamp('2016-02-29 23:59:59.123456780','yyyy-mm-dd hh24:mi:ssxff9')" },
      {type_name: 'any_data_timestamp_tz',
       other_data_value: "to_timestamp_tz('2016-02-29 23:59:59.123456789 -01:00','yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm')",
       data_value: "to_timestamp_tz('2016-02-29 23:59:59.123456789  00:00','yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm')" },
      {type_name: 'any_data_timestamp_ltz',
       other_data_value: "to_timestamp_tz('2016-02-29 23:59:59.123456789 -01:00','yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm')",
       data_value: "to_timestamp_tz('2016-02-29 23:59:59.123456789  00:00','yyyy-mm-dd hh24:mi:ssxff9 tzh:tzm')" },
    ].each do |element|

      describe element[:type_name] do
        include_examples 'any data comparable types', element[:type_name], element[:data_value], element[:type_name], element[:other_data_value]
        include_examples 'any data null comparison', element[:type_name], element[:data_value]
      end

    end

  end

  context 'scalar types from the same family' do
    [
      [
        {type_name: 'any_data_bdouble',  data_value: 123.125 },
        {type_name: 'any_data_bfloat',   data_value: 1234.125 },
        {type_name: 'any_data_number',   data_value: 1235.125 },
      ],
      [
        {type_name: 'any_data_blob',     data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
        {type_name: 'any_data_raw',      data_value: "utl_raw.cast_to_raw('9234%$#$%DRGSDFG$#%')" },
      ],
      [
        {type_name: 'any_data_char',     data_value: "'A char'" },
        {type_name: 'any_data_varchar',  data_value: "'A varchar'" },
        {type_name: 'any_data_varchar2', data_value: "'A varchar2'" },
        {type_name: 'any_data_clob',     data_value: "'Clob value'||'#{('a'*32000)}'"},
      ],
      [
        {type_name: 'any_data_date',          data_value: "to_date('2016-02-25','yyyy-mm-dd')" },
        {type_name: 'any_data_timestamp',     data_value: "to_timestamp('2016-02-25 23:59:59.123456780','yyyy-mm-dd hh24:mi:ssxff')"},
        {type_name: 'any_data_timestamp_ltz', data_value: "to_timestamp_tz('2016-02-25 23:59:59.123456789 -01:00','yyyy-mm-dd hh24:mi:ssxff tzh:tzm')"},
        {type_name: 'any_data_timestamp_tz',  data_value: "to_timestamp_tz('2016-02-25 23:59:59.123456789 -02:00','yyyy-mm-dd hh24:mi:ssxff tzh:tzm')"},
      ],
    ].each do |family|

      family.permutation(2).to_a.each do |left, right|

        describe "compares #{left[:type_name]} with #{right[:type_name]}" do

          include_examples 'any data comparable types', left[:type_name], left[:data_value], right[:type_name], right[:data_value]

        end

      end

    end
  end

  context 'scalar types from different families' do

    it 'returns NULL if data is of different families' do
      expect(
        compare('any_data_number', 1, 'any_data_varchar2', '1')
      ).to be_nil
    end

  end

  context 'complex types' do

    context 'any_data_attribute' do

      it 'returns 0 for identical attributes' do
        expect(
          compare(
            'any_data_attribute', "'element', any_data_number(2)",
            'any_data_attribute', "'element', any_data_number(2)"
          )
        ).to eq 0
      end

      it 'returns 0 regardless of attribute name case' do
        expect(
          compare(
            'any_data_attribute', "'A', any_data_number(2)",
            'any_data_attribute', "'a', any_data_number(2)"
          )
        ).to eq 0
      end

      it 'returns 1 for attribute name greater than compared' do
        expect(
          compare(
            'any_data_attribute', "'b', any_data_number(2)",
            'any_data_attribute', "'a', any_data_number(2)"
          )
        ).to eq 1
      end

      it 'returns -1 for attribute name less than compared' do
        expect(
          compare(
            'any_data_attribute', "'A', any_data_number(2)",
            'any_data_attribute', "'B', any_data_number(2)"
          )
        ).to eq -1
      end

      it 'returns 1 if attribute data is less' do
        expect(
          compare(
            'any_data_attribute', "'a', any_data_number(2)",
            'any_data_attribute', "'a', any_data_number(1)"
          )
        ).to eq 1
      end

      it 'returns -1 if attribute data is greater' do
        expect(
          compare(
            'any_data_attribute', "'a', any_data_number(1)",
            'any_data_attribute', "'a', any_data_number(2)"
          )
        ).to eq -1
      end

      it 'returns NULL when one of attributes data is NULL' do
        expect(
          compare(
            'any_data_attribute', "'a', NULL",
            'any_data_attribute', "'a', any_data_number(2)"
          )
        ).to be_nil
        expect(
          compare(
            'any_data_attribute', "'a', any_data_number(2)",
            'any_data_attribute', "'a', NULL"
          )
        ).to be_nil
      end

      it 'returns 0 when both attributes data is NULL' do
        expect(
          compare(
            'any_data_attribute', "'a', NULL",
            'any_data_attribute', "'a', NULL"
          )
        ).to eq 0
      end

      it 'returns NULL when attribute contain data from different families' do
        expect(
          compare(
            'any_data_attribute', "'a', any_data_number(2)",
            'any_data_attribute', "'a', any_data_varchar2('2')",
          )
        ).to be_nil
      end


    end

    context 'any_data_collection' do

      it 'returns 0 for identical collections' do
        expect(
          compare(
            'any_data_collection', "'a_collection', any_data_tab( any_data_number(2) )",
            'any_data_collection', "'a_collection', any_data_tab( any_data_number(2) )"
          )
        ).to eq 0
      end

      it 'returns 0 for collections containing the same elements regardless of collection type name' do
        expect(
          compare(
            'any_data_collection', "'a_collection',          any_data_tab( any_data_number(2) )",
            'any_data_collection', "'some_other_collection', any_data_tab( any_data_number(2) )"
          )
        ).to eq 0
      end

      it 'returns 1 of compared collection is less' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(2), any_data_number(2) )",
            'any_data_collection', "'coll', any_data_tab( any_data_number(2) )"
          )
        ).to eq 1
      end

      it 'returns -1 of compared collection is greater' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(2) )",
            'any_data_collection', "'coll', any_data_tab( any_data_number(2), any_data_number(2) )"
          )
        ).to eq -1
      end

      it 'returns 1 if collections are of equal size but compared collections element is less' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(2) )",
            'any_data_collection', "'coll', any_data_tab( any_data_number(1) )"
          )
        ).to eq 1
      end

      it 'returns -1 if collections are of equal size but compared collections element is greater' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(1) )",
            'any_data_collection', "'coll', any_data_tab( any_data_number(2) )"
          )
        ).to eq -1
      end

      it 'returns NULL when one of collections data is NULL' do
        expect(
          compare(
            'any_data_collection', "'coll', NULL",
            'any_data_collection', "'coll', any_data_tab( any_data_number(2) )"
          )
        ).to be_nil
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(2) )",
            'any_data_collection', "'coll', NULL"
          )
        ).to be_nil
      end

      it 'returns 0 when both collections data is NULL' do
        expect(
          compare(
            'any_data_collection', "'coll', NULL",
            'any_data_collection', "'coll', NULL"
          )
        ).to eq 0
      end

      it 'returns 0 when both collections data is contain NULL elements' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( null )",
            'any_data_collection', "'coll', any_data_tab( null )"
          )
        ).to eq 0
      end

      it 'returns NULL when collections contain data from different families' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(1) )",
            'any_data_collection', "'coll', any_data_tab( any_data_varchar2('1') )"
          )
        ).to be_nil
      end

      it 'returns 0 when collections contain data from common family' do
        expect(
          compare(
            'any_data_collection', "'coll', any_data_tab( any_data_number(1) )",
            'any_data_collection', "'coll', any_data_tab( any_data_bfloat(1) )"
          )
        ).to eq 0
      end

    end

    context 'any_data_object' do

      it 'returns 0 for identical objects' do
        expect(
          compare(
            'any_data_object', "'a_object', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )",
            'any_data_object', "'a_object', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )"
          )
        ).to eq 0
      end

      it 'returns 0 for objects regardless of object type name' do
        expect(
          compare(
            'any_data_object', "'a_object',          any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )",
            'any_data_object', "'some_other_object', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )"
          )
        ).to eq 0
      end

      it 'returns 1 of compared object is less' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) , any_data_attribute('attribute_name', any_data_number(2) ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )"
          )
        ).to eq 1
      end

      it 'returns -1 of compared object is greater' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ), any_data_attribute('attribute_name', any_data_number(2) ) )"
          )
        ).to eq -1
      end

      it 'returns 1 if objects are of equal size but compared objects element is less' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(1) ) )"
          )
        ).to eq 1
      end

      it 'returns -1 if objects are of equal size but compared objects element is greater' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(1) ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )"
          )
        ).to eq -1
      end

      it 'returns NULL when one of objects data is NULL' do
        expect(
          compare(
            'any_data_object', "'coll', NULL",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )"
          )
        ).to be_nil
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(2) ) )",
            'any_data_object', "'coll', NULL"
          )
        ).to be_nil
      end

      it 'returns 0 when both objects data is NULL' do
        expect(
          compare(
            'any_data_object', "'coll', NULL",
            'any_data_object', "'coll', NULL"
          )
        ).to eq 0
      end

      it 'returns 0 when both objects data is contain NULL elements' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', null ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', null ) )"
          )
        ).to eq 0
      end

      it 'returns NULL when objects contain data from different families' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(1) ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_varchar2('1') ) )"
          )
        ).to be_nil
      end

      it 'returns 0 when objects contain data from common family' do
        expect(
          compare(
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_number(1) ) )",
            'any_data_object', "'coll', any_data_tab( any_data_attribute('attribute_name', any_data_bfloat(1) ) )"
          )
        ).to eq 0
      end

    end

  end


end
