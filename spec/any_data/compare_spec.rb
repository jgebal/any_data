def method_name(other_type, other_value, type, value)
  result = compare(type, other_value, other_type, value)
end

shared_examples 'any data comparable types' do |type, value, other_type, other_value|

  def compare(type, value, other_type, other_value, nulls_are_equal = 'N')
    sql = <<-SQL
      BEGIN
        :x := #{type}( #{value} ).compare( #{other_type}( #{other_value} ), '#{nulls_are_equal}' );
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'NUMBER', :in_out => 'OUT')
    cursor.exec
    cursor[":x"]
  end

  context 'non null values comparison' do

    it 'returns 0 if both objects hold equal values' do
      expect(compare(type, value, other_type, value)).to eq 0
    end

    it 'returns -1 if self object value is bigger' do
      expect(compare(type, value, other_type, other_value)).to eq -1
    end

    it 'returns 1 if compared object value is bigger' do
      expect(method_name(other_type, other_value, type, value)).to eq 1
    end

  end

  context 'null values comparison' do

    context 'default' do

      it 'returns null if self object holds null value' do
        expect(compare(type, 'NULL', other_type, other_value)).to be_nil
      end

      it 'returns null if compared object holds null value' do
        expect(compare(type, value, other_type, 'NULL')).to be_nil
      end

      it 'returns null if both objects holds null value' do
        expect(compare(type, 'NULL', other_type, 'NULL')).to be_nil
      end

    end

    context "with p_nulls_are_equal = 'Y'" do

      it 'returns -1 if self object holds null value' do
        expect(compare(type, 'NULL', other_type, other_value, 'Y')).to eq -1
      end

      it 'returns 1 if compared object holds null value' do
        expect(compare(type, value, other_type, 'NULL', 'Y')).to eq 1
      end

      it 'returns 0 if both objects holds null value' do
        expect(compare(type, 'NULL', other_type, 'NULL', 'Y')).to eq 0
      end

    end

  end

end


describe 'any data compare' do

  context 'compare identical types' do
    [
      {type_name: 'any_data_bdouble',  other_data_value: 987.654321,                            data_value: 123.456789 },
      {type_name: 'any_data_bfloat',   other_data_value: 521.321,                               data_value: 123.125 },
      {type_name: 'any_data_number',   other_data_value: 6,                                     data_value: 3 },
      {type_name: 'any_data_blob',     other_data_value: "utl_raw.cast_to_raw('324$#%')",       data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
      {type_name: 'any_data_raw',      other_data_value: "utl_raw.cast_to_raw('324$#%')",       data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
      {type_name: 'any_data_clob',     other_data_value: "'Different value'||'#{('a'*32767)}'", data_value: "'Clob value'||'#{('a'*32767)}'"},
      {type_name: 'any_data_char',     other_data_value: "'B'",                                 data_value: "'A'" },
      {type_name: 'any_data_date',     other_data_value: "TO_DATE('2016-02-29','YYYY-MM-DD')",  data_value: "TO_DATE('2016-02-25','YYYY-MM-DD')" },
      {type_name: 'any_data_varchar',  other_data_value: "'Other varchar'",                     data_value: "'A varchar'" },
      {type_name: 'any_data_varchar2', other_data_value: "'Other varchar2'",                    data_value: "'A varchar2'" },
    ].each do |element|

      describe element[:type_name] do
        include_examples 'any data comparable types', element[:type_name], element[:data_value], element[:type_name], element[:other_data_value]
      end

    end
  end


end