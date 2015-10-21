require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    it 'should call the model method that performs TMDb search' do
      Movie.should_receive(:find_in_tmdb).with('hardware').
        and_return(@fake_results)
      post :search_tmdb, {:search_terms => 'hardware'}
    end
    
    describe 'after valid search' do
      before :each do
        Movie.stub(:find_in_tmdb).and_return(@fake_results)
        post :search_tmdb, {:search_terms => 'hardware'}
      end
      
      it 'should select the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'should make the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
      
    describe 'after sad paths'
      it 'should return to the movies page if no results are found' do
        Movie.stub(:find_in_tmdb).and_return([])
        post :search_tmdb, {:search_terms => 'hardware'}
        
        expect(flash[:notice]).to eq("No matching movies were found on TMDb")
        expect(response).to redirect_to(movies_path)
      end
      
      it 'should return to the movies page for an invalid search' do
        post :search_tmdb, {:search_terms => ''}
        
        expect(flash[:warning]).to eq("Invalid search term")
        expect(response).to redirect_to(movies_path)
      end
    end
  end
  
  describe 'adding TMDb movies' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    it 'should call the model method that adds the TMDb movie' do
      Movie.should_receive(:create_from_tmdb).with("123")
      Movie.should_receive(:create_from_tmdb).with("456")
      post :add_tmdb, {"tmdb_movies" => {"123" => "1", "456" => "1"}}
    end
    it 'should return to the movies page if nothing was selected' do
      post :add_tmdb, {}
      expect(flash[:notice]).to eq("No movies were added")
      expect(response).to redirect_to(movies_path)
    end
    
    it 'should return to the movies page if movies were selected' do
      post :add_tmdb, {"tmdb_movies" => {"123" => "1", "456" => "1"}}
      expect(flash[:notice]).to eq("Movies successfully added to Rotten Potatoes")
      expect(response).to redirect_to(movies_path)
    end
  end
  
  describe 'MoviesController#show' do
    it 'should return the movie specified' do
      Movie.should_receive(:find).with("123")
      get :show, {'id' => 123}
    end
  end
end