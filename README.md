# Harris County Court Scraper

This is a scraper written to scrape contents of [harris county court](https://www.cclerk.hctx.net/applications/websearch/CourtSearch.aspx?CaseType=Civil).

The only dependency is **mechanize** gem.

Either install it manually `gem install mechanize`
or
Use `bundle install`

An example of the scraper is given in [example.rb](https://github.com/andreyuhai/harris-county-court-scraper/blob/master/example.rb) file and also  below:
```ruby
require_relative 'lib/harris_county_court_scraper'  
  
# Create a scraper with given credentials  
harris_country_scraper = HarrisCountyCourtScraper.new(  
  Logger.new('error.log'),  
  db_username: 'DB_USERNAME',  
  db_password: 'DB_PASSWORD',  
  db_name: 'DB_NAME',  
  host: 'HOST',  
  created_by: 'CREATED_BY'  
)  
  
# You can scrape between particular dates
harris_country_scraper.scrape_between('MM/DD/YYYY', 'MM/DD/YYYY')

# Or you can scrape daily with the help of cronjobs
# The method below just scrapes once for the current date
harris_county_scraper.scrape_daily
```



