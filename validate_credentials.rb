require "uri"
require "net/http"
require "open-uri"
#Return if and only if a given first and last name matches up with an active CNA number
def validate_credentials first_name, last_name, license_number, state=:ca
    #Create Request
    case state
    when :ca
        uri = URI.parse("http://www.apps.cdph.ca.gov/cvl/SearchPage.aspx")
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data(
        { 
                "__EVENTTARGET" => "",
                "__EVENTARGUMENT" => "",
                "__LASTFOCUS" => "",
                "__VIEWSTATE" => "/wEPDwULLTE2MzU0Nzc0ODAPZBYCZg9kFgICAw9kFgICAQ9kFgYCAQ8PFgQeBFRleHQFXWNsaWNrIGhlcmUgdG8gc2VuZCANCiAgICAgICBhbiBlLW1haWwgdG8gdGhlIEFpZGUgYW5kIFRlY2huaWNpYW4gQ2VydGlmaWNhdGlvbiBTZWN0aW9uIChBVENTKR4LTmF2aWdhdGVVcmwFFUNWTE1haWwuYXNweD9tb2RlPUFUQ2RkAgIPDxYEHwAFS2NsaWNrIGhlcmUgdG8gc2VuZCBhbiBlLW1haWwgDQogICAgICAgdG8gTnVyc2luZyBIb21lIEFkbWluaXN0cmF0b3IgUHJvZ3JhbR8BBRVDVkxNYWlsLmFzcHg/bW9kZT1OSEFkZAIDD2QWAmYPZBYYAgEPEA8WAh4LXyFEYXRhQm91bmRnZBAVBQNBbGwhQ2VydGlmaWVkIEhlbW9kaWFseXNpcyBUZWNobmljaWFuGUNlcnRpZmllZCBOdXJzZSBBc3Npc3RhbnQQSG9tZSBIZWFsdGggQWlkZRpOdXJzaW5nIEhvbWUgQWRtaW5pc3RyYXRvchUFATADQ0hUA0NOQQNISEEDTkhBFCsDBWdnZ2dnFgFmZAIDDxAPFgQeB0NoZWNrZWRoHgdFbmFibGVkaBYCHgtPbk1vdXNlRG93bgUYcmRvVHlwZU5vX09uTW91c2VEb3duKCk7ZGRkAgUPDxYIHglCYWNrQ29sb3IKpAEeBF8hU0ICCB8AZR8EaGRkAgcPDxYEHwAFASoeB1Zpc2libGVoZGQCCQ8QDxYCHwNoFgIfBQUbcmRvTGFzdEZpcnN0X09uTW91c2VEb3duKCk7ZGRkAgsPDxYEHwYKpAEfBwIIZGQCDQ8PFgQfAAUBKh8IaGRkAg8PDxYEHwYKpAEfBwIIZGQCEQ8QD2QWAh8FBRtyZG9MYXN0U3RhcnRfT25Nb3VzZURvd24oKTtkZGQCEw8PFgQfBgpnHwcCCGRkAhkPDxYEHwAFCiogUmVxdWlyZWQfCGhkZAIbDw8WBB8ABS9QbGVhc2UgZW50ZXIgYSBmdWxsIG9yIHBhcnRpYWwgbGFzdCBuYW1lLjxiciBcPh8IZ2RkGAIFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYDBTFjdGwwMCRDb250ZW50UGxhY2VIb2xkZXJNaWRkbGVDb2x1bW4kcmRvTGFzdEZpcnN0BTFjdGwwMCRDb250ZW50UGxhY2VIb2xkZXJNaWRkbGVDb2x1bW4kcmRvTGFzdEZpcnN0BTFjdGwwMCRDb250ZW50UGxhY2VIb2xkZXJNaWRkbGVDb2x1bW4kcmRvTGFzdFN0YXJ0BS1jdGwwMCRDb250ZW50UGxhY2VIb2xkZXJNaWRkbGVDb2x1bW4kbXZTZWFyY2gPD2RmZA==",
                "ctl00$ContentPlaceHolderMiddleColumn$ddlCertType" => "0",
                "ctl00$ContentPlaceHolderMiddleColumn$txtCertNumber" => "",
                "ctl00$ContentPlaceHolderMiddleColumn$CVLSearch" => "rdoLastFirst",
                "ctl00$ContentPlaceHolderMiddleColumn$txtLastName" => last_name,
                "ctl00$ContentPlaceHolderMiddleColumn$txtFirstName" => first_name,
                "ctl00$ContentPlaceHolderMiddleColumn$txtLastNameStart" => "",
                "ctl00$ContentPlaceHolderMiddleColumn$btnSearch2" => "Search"
            }
        )
        response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request)}
    else
        return nil
    end
    #Parse Response
    case state
        when :ca
            response = open("http://www.apps.cdph.ca.gov/cvl/ListPage.aspx","Cookie"=>response['set-cookie'].split('; ',2)[0]).read.to_s
            response = response.gsub("\n","")
            response = response.gsub("\t","")
            response = response.gsub("\r","")
            response = response.gsub('"','')
            #return response
            candidates = response.scan(/<tr>(.*?)<\/tr>/);
            candidates.shift()
            candidates.each do |can|
                can = can.to_s
                if(can.include?(license_number) && can.include?("ACTIVE"))
                    return true
                end
            end
        else
            return nil
    end
    return false
end