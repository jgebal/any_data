describe 'Formatter indent lines function' do

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
