describe 'any_data' do

  it 'returns current version number' do
    full_file_path = File.expand_path('../../../VERSION.sql', __FILE__)
    file_contents = File.read(full_file_path).chomp
    expected = file_contents.sub(/.*'([0-9]+\.[0-9]+\.[0-9]+)'/,"\\1")
    expect( plsql.any_data.get_version ).to eq expected
  end

end
