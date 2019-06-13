module RequestBody

  class << self

    # Returns a request body string for a search request
    def create_search_request(event_validation, view_state, date_from, date_to)
      event_validation = CGI.escape event_validation
      view_state = CGI.escape view_state
      date_from = CGI.escape date_from
      date_to = CGI.escape date_to

      "__VIEWSTATE=#{view_state}&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=#{event_validation}&ctl00%24ContentPlaceHolder1%24txtFrom=#{date_from}&ctl00%24ContentPlaceHolder1%24txtTo=#{date_to}&ctl00%24ContentPlaceHolder1%24btnSearchCase=Search"
    end

    # Returns a request body string for a case detail request
    def create_case_details_request(event_validation, view_state, target_index)
      event_validation = CGI.escape event_validation
      view_state = CGI.escape view_state

      "__EVENTTARGET=ctl00%24ContentPlaceHolder1%24ListViewCases%24ctrl#{target_index}%24btnSelect&__VIEWSTATE=#{view_state}&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=#{event_validation}"
    end

    # Returns a request body string for a next page request
    def create_next_page_request(event_validation, view_state, date_from, date_to)
      event_validation = CGI.escape event_validation
      view_state = CGI.escape view_state
      date_from = CGI.escape date_from
      date_to = CGI.escape date_to

      "__EVENTTARGET=ctl00%24ContentPlaceHolder1%24DataPagerLisViewCases1%24ctl03%24ctl00&__VIEWSTATE=#{view_state}&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=#{event_validation}&ctl00%24ContentPlaceHolder1%24txtDateFrom=#{date_from}&ctl00%24ContentPlaceHolder1%24txtDateTo=#{date_to}"
    end
  end


end