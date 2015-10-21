require 'spec_helper'
require 'rails_helper'
include MoviesHelper
 
describe MoviesHelper do
   it 'should be return odd for odd numbers' do
       expect(oddness(5)).to eq("odd")
   end
   it 'should be return even for odd numbers' do
       expect(oddness(4)).to eq("even")
   end
end