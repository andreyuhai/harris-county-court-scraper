require 'mechanize'
require_relative 'request'
require 'pry'

class Scraper
  attr_accessor :db, :agent, :page_event_validation, :page_view_state, :created_by

  def initialize(created_by)
    @agent = Mechanize.new
    @created_by = created_by
  end

  def search_between(date_from, date_to)
    response = @agent.get 'https://www.cclerk.hctx.net/applications/websearch/CourtSearch.aspx?CaseType=Civil'
    parsed_response_body = Nokogiri::HTML(response.body)

    event_validation = find_event_validation(parsed_response_body)
    view_state = find_view_state(parsed_response_body)

    request_body = Request::Body.create_search_request(event_validation, view_state, date_from, date_to)
    request_header = Request::Header.create(request_body.length, @agent.page.uri)

    uri = 'https://www.cclerk.hctx.net/applications/websearch/CourtSearch.aspx?CaseType=Civil'
    response = @agent.post(uri, request_body, request_header)
    new_page_params(response)

    response
  end

  def navigate_to_case_details(case_index)
    request_body = Request::Body.create_case_detail_request(@page_event_validation, @page_view_state, case_index)
    request_header = Request::Header.create(request_body.length, @agent.page.uri.to_s)

    uri = @agent.page.uri
    @agent.post(uri, request_body, request_header)
  end

  def get_next_page(date_from, date_to)
    request_body = Request::Body.create_next_page_request(@page_event_validation, @page_view_state, date_from, date_to)
    request_header = Request::Header.create(request_body.length, @agent.page.uri.to_s)

    uri = @agent.page.uri
    response = @agent.post(uri, request_body, request_header)
    new_page_params(response)

    response
  end

  def find_view_state(parsed_response_body)
    CGI.escape(parsed_response_body.css('#__VIEWSTATE').attr('value').text)
  end

  def find_event_validation(parsed_response_body)
    CGI.escape(parsed_response_body.css('#__EVENTVALIDATION').attr('value').text)
  end

  def new_page_params(response)
    parsed_response_body = Nokogiri::HTML(response.body)

    @page_view_state = find_view_state(parsed_response_body)
    @page_event_validation = find_event_validation(parsed_response_body)
  end

  def scrape_case(response)
    parsed_response_body = Nokogiri::HTML(response.body)

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

  def scrape_case_activities(response)
    parsed_response_body = Nokogiri::HTML(response.body)

    case_number = parsed_response_body.xpath("//table[@id='ctl00_ContentPlaceHolder1_gridViewCase']/tr[2]/td[2]").text.strip.to_i
    case_activity_rows = parsed_response_body.xpath("//table[@id='ctl00_ContentPlaceHolder1_gridViewEvents']/tr").drop(1)
    activities = []
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

  def count_case_elements(response)
    parsed_response_body = Nokogiri::HTML(response.body)
    parsed_response_body.xpath("//tr[@class='even']").count
  end
end

