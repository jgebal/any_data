describe 'Indent lines in a string' do

  it 'returns a single line string indented' do
    expect( plsql.any_data_formatter.indent_lines('aa') ).to eq '   aa'
  end

  it 'returns NULL for NULL input' do
    expect( plsql.any_data_formatter.indent_lines(p_string:NULL) ).to eq NULL
  end

  it 'returns a string with lines indented' do
    input = 'aaa
bbb
ccc'
    expected = '   aaa
   bbb
   ccc'
    expect( plsql.any_data_formatter.indent_lines(input) ).to eq expected
  end

end

describe 'Indent elements of an array' do

  it 'returns a single line string indented' do
    expect( plsql.any_data_formatter.indent_lines(['aa']) ).to eq ['   aa']
  end

  it 'returns NULL for NULL input' do
    expect( plsql.any_data_formatter.indent_lines(p_lines:NULL) ).to eq NULL
  end

  it 'returns a string with lines indented' do
    input = %w(aaa bbb ccc)
    expected = ['   aaa','   bbb','   ccc']
    expect( plsql.any_data_formatter.indent_lines(input) ).to eq expected
  end

end
