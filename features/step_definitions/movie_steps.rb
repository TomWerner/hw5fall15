# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "([^\"]*)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  #pending  # Remove this statement when you finish implementing the test step
  movies_table.hashes.each do |movie|
      Movie.create!(movie)
  end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
    ratings = arg1.split(/\s*,\s*/)
    uncheck("ratings_G")
    uncheck("ratings_PG")
    uncheck("ratings_PG-13")
    uncheck("ratings_R")
    uncheck("ratings_NC-17")
    
    ratings.each do |rating|
        check("ratings_#{rating.to_s}")
    end
    
    click_button "Refresh"
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
    ratings = arg1.split(/\s*,\s*/)
    
    movieCount = 0
    ratings.each do |rating|
        Movie.where(:rating => rating).find_each do |movie|
            expect(page).to have_content(movie.title)
            movieCount += 1
        end
    end
    # -1 because there is a tr for the header
    (all("tr").count - 1).should == movieCount
end

Then /^I should see all of the movies$/ do
    Movie.all.find_each do |movie|
        expect(page).to have_content(movie.title)
    end
end

When /^I sort movies by "(.*?)"$/ do |sortBy|
    guiSortMap = {"Title" => "Movie Title", "Release Date" => "Release Date"}
    click_on(guiSortMap[sortBy])
end


Then /^the movies should sorted by "(.*?)"$/ do |sortedBy|
    dbSortMap = {"Title" => :title, "Release Date" => :release_date}
    expected = Movie.order(dbSortMap[sortedBy] => :asc).all
    
    find("tbody").all("tr").each_with_index do |row, index|
        expect(row).to have_content(expected[index].title)
        expect(row).to have_content(expected[index].release_date)
    end
end

