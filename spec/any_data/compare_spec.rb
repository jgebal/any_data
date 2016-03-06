
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

  value, other_value = value<other_value ? [value, other_value] : [other_value, value]
  include_context 'compare'

  context 'non null values comparison' do

    it 'returns 0 if both objects hold equal values' do
      expect(compare(type, value, other_type, value)).to eq 0
    end

    it 'returns -1 if self object value is bigger' do
      expect(compare(type, value, other_type, other_value)).to eq -1
    end

    it 'returns 1 if compared object value is bigger' do
      expect(compare(other_type, other_value, type, value)).to eq 1
    end

  end

end

shared_examples 'any data null comparison' do |type, value, null_values|

  include_context 'compare'

  context 'NULL values comparison' do

    null_values.each do |null_value|

      it "returns NULL if self object holds #{null_value} value" do
        expect(compare(type, null_value, type, value)).to be_nil
      end

      it "returns NULL if compared object holds #{null_value} value" do
        expect(compare(type, value, type, null_value)).to be_nil
      end

      it "returns NULL if both objects holds #{null_value} value" do
        expect(compare(type, null_value, type, null_value)).to be_nil
      end

    end

  end

end


describe 'any data compare' do

  context 'compare identical types' do
    [
      {type_name: 'any_data_bdouble',    null_values: ['NULL'], other_data_value: 987.654321,                            data_value: 123.456789 },
      {type_name: 'any_data_bfloat',     null_values: ['NULL'], other_data_value: 521.321,                               data_value: 123.125 },
      {type_name: 'any_data_number',     null_values: ['NULL'], other_data_value: 6,                                     data_value: 3 },
      {type_name: 'any_data_blob',       null_values: ['NULL'], other_data_value: "utl_raw.cast_to_raw('324$#%')",       data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
      {type_name: 'any_data_raw',        null_values: ['NULL'], other_data_value: "utl_raw.cast_to_raw('324$#%')",       data_value: "utl_raw.cast_to_raw('1234%$#$%DRGSDFG$#%')" },
      {type_name: 'any_data_clob',       null_values: ['NULL'], other_data_value: "'Different value'||'#{('a'*32767)}'", data_value: "'Clob value'||'#{('a'*32767)}'"},
      {type_name: 'any_data_char',       null_values: ['NULL'], other_data_value: "'B'",                                 data_value: "'A'" },
      {type_name: 'any_data_varchar',    null_values: ['NULL'], other_data_value: "'Other varchar'",                     data_value: "'A varchar'" },
      {type_name: 'any_data_varchar2',   null_values: ['NULL'], other_data_value: "'Other varchar2'",                    data_value: "'A varchar2'" },
      {type_name: 'any_data_date',       null_values: ['NULL'], other_data_value: "TO_DATE('2016-02-29','YYYY-MM-DD')",  data_value: "TO_DATE('2016-02-25','YYYY-MM-DD')" },
      {type_name: 'any_data_collection', null_values: ['NULL'], other_data_value: 'any_data_tab(any_data_number(2))',    data_value: 'any_data_tab(any_data_number(1))'},
      {type_name: 'any_data_attribute',  null_values: ["'A',NULL","NULL, any_data_varchar('A varchar')"], other_data_value: "'A', any_data_varchar('Other')",      data_value: "'A', any_data_varchar('A varchar')"},
    ].each do |element|

      describe element[:type_name] do
        include_examples 'any data comparable types', element[:type_name], element[:data_value], element[:type_name], element[:other_data_value]
        include_examples 'any data null comparison', element[:type_name], element[:data_value], element[:null_values]
      end

    end

  end

  context 'compare types from the same family' do
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
      # [
      #   {type_name: 'any_data_date',     data_value: "TO_DATE('2016-02-25','YYYY-MM-DD')" },
      # ],
    ].each do |family|

      family.permutation(2).to_a.each do |left, right|

        describe "compares #{left[:type_name].upcase} with #{right[:type_name].upcase}" do

          include_examples 'any data comparable types', left[:type_name], left[:data_value], right[:type_name], right[:data_value]

        end

      end

    end
  end

  context 'compare types from different families' do

    include_context 'compare'

    it 'returns NULL if objects are from different families' do
      expect(
        compare('any_data_number', 1, 'any_data_varchar2', '1')
      ).to be_nil
    end

  end

end
