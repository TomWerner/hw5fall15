require 'spec_helper'
require 'rails_helper'
 
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid API key' do
      it 'should call Tmdb with title keywords' do
        Tmdb::Movie.should_receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
      
      it 'should correctly extract the information' do
        Tmdb::Movie.should_receive(:find).with('Inception').and_return(
            [Tmdb::Movie.new({id:1, title: "Inception", release_date: "2010-07-16"}),],
        )
        Tmdb::Movie.should_receive(:detail).with(1).and_return(
          { 'overview' => "The description" }  
        )
        #Tmdb::Movie.should_receive(:releases).with(1).and_return(
        #  { 'countries' => [{'primary' => true, 'certification' => 'PG-13'}] }
        #)
        result = Movie.find_in_tmdb('Inception')
        
        expect(result.count).to eq(1)
        expect(result[0][:tmdb_id]).to eq(1)
        expect(Movie.all_ratings).to include(result[0][:rating])
        expect(result[0][:title]).to eq("Inception")
        expect(result[0][:description]).to eq("The description")
        expect(result[0][:release_date]).to eq("2010-07-16")
      end
      
    end
    context 'with invalid API key' do
      before :each do
        Tmdb::Movie.stub(:find).and_raise(NoMethodError)
        Tmdb::Api.stub(:response).and_return({'code' => '401'})
      end        
      it 'should raise an InvalidKeyError with no API key' do
        lambda { Movie.find_in_tmdb('Inception') }.
          should raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  
  describe 'adding from Tmdb' do
    context 'with valid API key' do
      before :each do
        Tmdb::Movie.should_receive(:detail).with(123).and_return(
          { 'overview' => "The description", "release_date" => "1990-10-14", "title" => "Inception" }  
        )
      end  
      it 'should call Tmdb with id' do
        Movie.create_from_tmdb('123')
      end
      
      it 'should correctly extract the information' do
        #Tmdb::Movie.should_receive(:releases).with(1).and_return(
        #  { 'countries' => [{'primary' => true, 'certification' => 'PG-13'}] }
        #)
        result = Movie.create_from_tmdb('123')
        
        expect(Movie.all_ratings).to include(result.rating)
        expect(result.title).to eq("Inception")
        expect(result.description).to eq("The description")
        expect(result.release_date).to eq("Sun, 14 Oct 1990 00:00:00 UTC +00:00")
      end
      
    end
    context 'with invalid API key' do
      before :each do
        Tmdb::Movie.stub(:detail).and_raise(NoMethodError)
        Tmdb::Api.stub(:response).and_return({'code' => '401'})
      end        
      it 'should raise an InvalidKeyError with no API key' do
        lambda { Movie.create_from_tmdb('123') }.
          should raise_error(Movie::InvalidKeyError)
      end
    end
  end
end