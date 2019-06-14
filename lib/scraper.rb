require 'mechanize'
require 'logger'
require_relative 'request'

class Scraper
  attr_accessor :db, :agent, :page_event_validation, :page_view_state, :created_by, :logger

  def initialize(created_by, logger)
    @agent = Mechanize.new
    @created_by = created_by
    @logger = logger
  end

  # Searches between two dates and returns the response.
  # @param [String] date_from
  # @param [String] date_to
  # @return [Mechanize::Page]
  def search_between(date_from, date_to)
    @logger.info('Navigating to the search page.')
    response = @agent.get 'https://www.cclerk.hctx.net/applications/websearch/CourtSearch.aspx?CaseType=Civil'
    parsed_response_body = Nokogiri::HTML(response.body)

    event_validation = find_event_validation(parsed_response_body)
    view_state = find_view_state(parsed_response_body)

    request_body = Request::Body.create_search_request(event_validation, view_state, date_from, date_to)
    request_header = Request::Header.create(request_body.length, @agent.page.uri)

    @logger.info("Searching between dates #{date_from} - #{date_to}")
    uri = 'https://www.cclerk.hctx.net/applications/websearch/CourtSearch.aspx?CaseType=Civil'
    response = @agent.post(uri, request_body, request_header)
    new_page_params(response)

    response
  end

  # Navigates to case details with the given case_index and returns the response.
  # @param [Integer] case_index
  # @return [Mechanize::Page]
  def navigate_to_case_details(case_index)
    request_body = Request::Body.create_case_detail_request(@page_event_validation, @page_view_state, case_index)
    request_header = Request::Header.create(request_body.length, @agent.page.uri.to_s)

    @logger.info("Navigating to the case index ##{case_index}")
    uri = @agent.page.uri
    @agent.post(uri, request_body, request_header)
  end

  # Fetches next page of the search results and returns it.
  # @param [String] date_from
  # @param [String] date_to
  # @return [Mechanize::Page]
  def get_next_page(date_from, date_to)
    request_body = Request::Body.create_next_page_request(@page_event_validation, @page_view_state, date_from, date_to)
    request_header = Request::Header.create(request_body.length, @agent.page.uri.to_s)

    @logger.info('Fetching next page')
    uri = @agent.page.uri
    response = @agent.post(uri, request_body, request_header)
    new_page_params(response)

    response
  end

  # Finds VIEWSTATE string on the given page.
  # @param [Nokogiri::HTML::Document] parsed_response_body
  def find_view_state(parsed_response_body)
    CGI.escape(parsed_response_body.css('#__VIEWSTATE').attr('value').text)
  end

  # Finds EVENTVALIDATION string on the given page.
  # @param [Nokogiri::HTML::Document] parsed_response_body
  def find_event_validation(parsed_response_body)
    CGI.escape(parsed_response_body.css('#__EVENTVALIDATION').attr('value').text)
  end

  # Sets new page parameters such as VIEWSTATE and EVENTVALIDATION.
  #
  # @param [Mechanize::Page] response
  def new_page_params(response)
    parsed_response_body = Nokogiri::HTML(response.body)

    @page_view_state = find_view_state(parsed_response_body)
    @page_event_validation = find_event_validation(parsed_response_body)
  end

  # Scrapes case details on a given page.
  # @param [Mechanize::Page] response
  # @return [Hash] containing all the details about the case.
  def scrape_case(response)
    parsed_response_body = Nokogiri::HTML(response.body)

    @logger.info('Scraping case details')
    case_detail_cells = parsed_response_body.xpath("//table[@id='ctl00_ContentPlaceHolder1_gridViewCase']/tr[2]/td")

    {
      case_number: case_detail_cells[1].text.strip.to_i,
      file_date: case_detail_cells[2].text.strip,
      type_desc: case_detail_cells[3].text.strip,
      subtype: case_detail_cells[4].text.strip,
      case_title: case_detail_cells[5].text.strip,
      status: case_detail_cells[6].text.strip,
      judge: case_detail_cells[7].text.strip,
      court_room: case_detail_cells[8].text.strip.to_i
    }
  end

  # Scrapes all the case activities and returns an array of hashes each containing a case activity.
  # @param [Mechanize::Page] response
  # @return [Array] of hashes each containing a case activity.
  def scrape_case_activities(response)
    parsed_response_body = Nokogiri::HTML(response.body)

    @logger.info('Scraping case activities')
    activities = []
    case_activity_rows = parsed_response_body.xpath("//table[@id='ctl00_ContentPlaceHolder1_gridViewEvents']/tr").drop(1)
    case_activity_rows.each do |row|
      activity_cells = row.xpath('td')
      activity = {
        date: activity_cells[1].text.strip,
        case_activity: activity_cells[2].text.strip,
        comments: activity_cells[3].text.strip
      }
      activities << activity
    end
    activities
  end

  # Returns the number of cases on a given search page.
  # @param [Mechanize::Page] response
  # @return [Integer] number of case elements on the given page.
  def count_case_elements(response)
    parsed_response_body = Nokogiri::HTML(response.body)
    parsed_response_body.xpath("//tr[@class='even']").count
  end

  def next_page?(response)
    parsed_response_body = Nokogiri::HTML(response.body)

    parsed_response_body.xpath("//a[@class='pgr' and .='Next']").attr('disabled').nil?
  end
end

