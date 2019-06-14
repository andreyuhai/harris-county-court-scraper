require_relative 'scraper'
require_relative 'database'
require_relative 'case'
require 'pry'

class HarrisCountyCourtScraper
  attr_accessor :scraper, :db, :case_table_name, :case_activity_table_name, :created_by, :logger

  def initialize(logger, **params)
    db_username = params.fetch(:db_username)
    db_password = params.fetch(:db_password)
    db_name     = params.fetch(:db_name)
    @created_by = params.fetch(:created_by)
    @logger = logger

    @scraper = Scraper.new(created_by, @logger)
    @db = Database.new(db_username, db_password, db_name)
    @case_table_name = "#{@created_by}_new_harris_county_court_scrape"
    @case_activity_table_name = "#{@created_by}_new_harris_county_court_case_activity_scrape"
    @db.create_case_table(@case_table_name)
    @db.create_case_activity_table(@case_activity_table_name)
  end

  def scrape_between(date_from, date_to)
    already_searched = false

    loop do
      response = if already_searched
                   @scraper.get_next_page(date_from, date_to)
                 else
                   already_searched = true
                   @scraper.search_between(date_from, date_to)
                 end
      next_page = @scraper.next_page?(response)

      case_index = 0
      num_of_case_elements = @scraper.count_case_elements(response)
      break if num_of_case_elements.zero?

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
      break unless next_page
    end
  end

  def scrape_daily
    today = Date.today.strftime('%-m/%-d/%Y')
    scrape_between(today, today)
  end
end