[
  { method: 'equality',         comparators: %w(equals eq "=\ "),          expected: [true,  false, false, false ]},
  { method: 'non equality',     comparators: %w(not_equals neq "!="),      expected: [false, true,  true,   true ]},
  { method: 'greater equal to', comparators: %w(greater_equal_to ge ">="), expected: [true,  true,  false, false ]},
  { method: 'greater than',     comparators: %w(greater_than gt ">\ "),    expected: [false, true,  false, false ]},
  { method: 'less equal to',    comparators: %w(less_equal_to le "<="),    expected: [true,  false, true,  false ]},
  { method: 'less than',        comparators: %w(less_than lt "<\ "),       expected: [false, false, true,  false ]},

].map{|a| a.values }.each do |method, comparators, expected|

  describe "any data #{method} comparison" do

    comparators.each do |method_name|

      equality_expected, lesser_expected, greater_expected, different_expected = expected

      describe "using #{method_name} method" do

        describe 'non NULL comparison' do
          it "returns #{equality_expected} for identical data" do
            expect( any_data_method( method_name, 'any_data_number', 1, 'any_data_number', 1 ) ).to eq equality_expected
          end

          it "returns #{lesser_expected} for when comparing to lesser value" do
            expect( any_data_method( method_name, 'any_data_number', 1, 'any_data_number', 0 ) ).to eq lesser_expected
          end

          it "returns #{greater_expected} for when comparing to greater value" do
            expect( any_data_method( method_name, 'any_data_number', 1, 'any_data_number', 3 ) ).to eq greater_expected
          end

          it "returns #{different_expected} for data types of different families" do
            expect( any_data_method( method_name,'any_data_number', 1, 'any_data_char', '1' ) ).to eq different_expected
          end

        end

        describe 'NULL comparison' do

          it "returns #{equality_expected} when comparing NULL to NULL" do
            expect( any_data_method( method_name, 'any_data_number', NULL, 'any_data_number', NULL ) ).to eq equality_expected
          end

          it "returns #{different_expected} when comparing to a NULL value" do
            expect( any_data_method( method_name,'any_data_number', 1, 'any_data_number', NULL ) ).to eq different_expected
          end

        end


      end

    end

  end

end
