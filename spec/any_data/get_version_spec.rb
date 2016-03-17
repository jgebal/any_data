describe 'library version' do

  %w(any_data any_data_builder any_type_mapper any_data_const any_data_formatter).each do |object|

    describe object + '.get_version' do

      before(:all) do
        full_file_path = File.expand_path('../../../VERSION.sql', __FILE__)
        file_content = File.read(full_file_path).chomp
        @version_in_file = file_content.sub(/define +VERSION *= *'([0-9]+\.[0-9]+\.[0-9]+)'/ ,"\\1")
      end

      it 'returns current project version number' do
        expect( plsql.send(object.to_sym).send(:get_version) ).to eq @version_in_file
      end

    end

  end

end
