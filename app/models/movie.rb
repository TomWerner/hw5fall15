class Movie < ActiveRecord::Base
  class Movie:: InvalidKeyError < StandardError; end;
    
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movies = Tmdb::Movie.find(string)
      #debugger
      result = []
      return result if movies == nil
      #debugger
      movies.each do |movie|
        description = Tmdb::Movie.detail(movie.id)['overview']
        
        rating = Movie.all_ratings.sample
        #Tmdb::Movie.releases(movie.id)['countries'].select {|x| x['iso_3166_1'] == "US"}[0]['certification']
        result.push({tmdb_id: movie.id, title: movie.title, description: description, rating: rating, release_date: movie.release_date})
      end
      
      return result
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == '401'
        raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end
    end
  end
  
  def self.create_from_tmdb(tmdb_id)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      tmdb_id = Integer(tmdb_id)
      #debugger
      details = Tmdb::Movie.detail(tmdb_id)
      Movie.create!({description: details["overview"], release_date:details["release_date"],
        title:details["title"], rating: Movie.all_ratings.sample
      })
      
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == '401'
        raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end
    end
  end
end
