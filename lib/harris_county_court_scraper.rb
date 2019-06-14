require_relative 'scraper'
require_relative 'database'
require_relative 'case'
require 'pry'

class HarrisCountyCourtScraper
  attr_accessor :scraper, :db, :case_table_name, :case_activity_table_name, :created_by

  def initialize(**params)
    db_username = params.fetch(:db_username)
    db_password = params.fetch(:db_password)
    db_name     = params.fetch(:db_name)
    @created_by = params.fetch(:created_by)

    @scraper = Scraper.new(created_by)
    @db = Database.new(db_username, db_password, db_name)
    @case_table_name = "#{@created_by}_new_harris_county_court_scrape"
    @case_activity_table_name = "#{@created_by}_new_harris_county_court_case_activity_scrape"
    @db.create_case_table(@case_table_name)
    @db.create_case_activity_table(@case_activity_table_name)
  end

  def scrape_between(date_from, date_to)
    response = @scraper.search_between(date_from, date_to)
    num_of_case_elements = @scraper.count_case_elements(response)
    case_index = 0
    (1..num_of_case_elements).each do
      response = @scraper.navigate_to_case_details(case_index)
      case_details = @scraper.scrape_case(response)
      case_obj = Case.new(@created_by, case_details)
      @db.insert_case(@case_table_name, case_obj.case_values)
      case_obj.case_activities = @scraper.scrape_case_activities(response)
      case_obj.case_activities.each do |activity|
        @db.insert_case_activity(@case_activity_table_name, case_obj.case_activity_values(activity))
      end
      case_index += 1
    end
  end

  def scrape_daily

  end
end




# db = Database.new('burak', '25ky7&9mc+', 'acme', 'burak')
# scraper = Scraper.new
# page = scraper.search_between('2/5/2019', '6/10/2019')
# #page = scraper.get_next_page('2/5/2019', '6/10/2019')
# page = scraper.navigate_to_case_details(0)
#
# db.create_case_table('burak_new_harris_county_court_scrape')
# db.insert_into_table('burak_new_harris_county_court_scrape')
# binding.pry