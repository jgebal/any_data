describe 'Splint new-lined clob to array of strings' do

  it 'returns empty array if null string given' do
    expect( plsql.any_data_formatter.split_nl_clob_to_array(NULL) ).to be_empty
  end

  it 'accepts a line size of up to 4000 chars' do
    value = ('a' * 4000)
    expect( plsql.any_data_formatter.split_nl_clob_to_array(value) ).to eq([value])
  end

  it 'fails for a line size above 4000 chars' do
    value = ('a' * 4001)
    expect{
      plsql.any_data_formatter.split_nl_clob_to_array(value)
    }.to raise_exception /character string buffer too small/
  end

  it 'returns a multi element array with one element representing one line' do
    value = "that is\na\nmulti\nline\ntext"
    expected = ['that is','a','multi','line', 'text']
    expect( plsql.any_data_formatter.split_nl_clob_to_array(value) ).to eq( expected )
  end

  it 'accepts a large CLOB and turns it into array' do
    lines = 2000
    value = (( 'a' * 40 )+"\n") * lines
    value.chomp!
    expected = value.split("\n")
    expect( plsql.any_data_formatter.split_nl_clob_to_array(value).count ).to eq( expected.count )
  end


end
