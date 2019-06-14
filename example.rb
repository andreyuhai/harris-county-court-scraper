require_relative 'lib/harris_county_court_scraper'

harris_country_scraper = HarrisCountyCourtScraper.new(
  Logger.new('error.log'),
  db_username: 'DB_USERNAME',
  db_password: 'DB_PASSWORD',
  db_name: 'DB_NAME',
  created_by: 'CREATED_BY'
)

harris_country_scraper.scrape_between('4/1/2019', '6/14/2019')