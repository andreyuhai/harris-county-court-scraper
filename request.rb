module Request
  module Body
    class << self
      # Returns a request body string for a search request
      def create_search_request(event_validation, view_state, date_from, date_to)
        date_from = CGI.escape date_from
        date_to = CGI.escape date_to

        "__VIEWSTATE=#{view_state}&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=#{event_validation}&ctl00%24ContentPlaceHolder1%24txtFrom=#{date_from}&ctl00%24ContentPlaceHolder1%24txtTo=#{date_to}&ctl00%24ContentPlaceHolder1%24btnSearchCase=Search"
      end

      # Returns a request body string for a case detail request
      def create_case_detail_request(event_validation, view_state, case_index)
        "__EVENTTARGET=ctl00%24ContentPlaceHolder1%24ListViewCases%24ctrl#{case_index}%24btnSelect&__VIEWSTATE=#{view_state}&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=#{event_validation}"
      end

      # Returns a request body string for a next page request
      def create_next_page_request(event_validation, view_state, date_from, date_to)
        date_from = CGI.escape date_from
        date_to = CGI.escape date_to

        "__EVENTTARGET=ctl00%24ContentPlaceHolder1%24DataPagerLisViewCases1%24ctl03%24ctl00&__VIEWSTATE=#{view_state}&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=#{event_validation}&ctl00%24ContentPlaceHolder1%24txtDateFrom=#{date_from}&ctl00%24ContentPlaceHolder1%24txtDateTo=#{date_to}"
      end
    end
  end

  module Header
    class << self
      def create(content_length, referer)
        {
            'Host' => 'www.cclerk.hctx.net',
            'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0',
            'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'tr,en-US;q=0.7,en;q=0.3',
            'Accept-Encoding' => 'gzip, deflate, br',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Content-Length' => content_length,
            'DNT' => 1,
            'Connection' => 'keep-alive',
            'Referer' => referer,
            'Upgrade-Insecure-Requests' => 1
        }
      end
    end
    # 'Origin' => 'https://www.ewccv.com',
    # 'X-MicrosoftAjax' => 'Delta=true',
    # 'X-Requested-With' => 'XMLHttpRequest'
  end

end