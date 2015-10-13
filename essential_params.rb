# This is a module for testing necessary params.
require 'byebug'

# TODO: try using rescues for stability.
# make the test cond its own method.
class Gets
  require 'active_support/core_ext/object/blank'
  require 'mechanize'
  require 'Rack'

  attr_reader :host, :params, :positive_test
  def initialize(url,is_test_true=true)
    @host = url.split('?').first
    @params = Rack::Utils.parse_query URI(url).query
    @positive_test = is_test_true
    @agent = Mechanize.new
  end

  def get_params
    essential_params @params
    pretty_print
  end

  def essential_params(in_question={},necessary={})
    trial_key = in_question.keys[0]
    trial_hash = in_question.except(trial_key)

    @params = trial_hash.merge(necessary)
    current_page = @agent.get(@host,@params)

    ##certification: write a valid test
    cond1 = current_page.body.present?
    cond = cond1 && current_page.at('.//div[@class="ratelink"]').present?
    cond = @positive_test ? cond : !cond

    necessary = cond ? necessary : necessary.merge(trial_key => in_question[trial_key])
    in_question.blank? ? necessary : essential_params(trial_hash,necessary)
  end

  def pretty_print
    puts "\n\n"
    @params.each{|hs|puts "param '#{hs[0]}', '#{hs[1]}'"}
    puts "\n\n"
  end
end

class Hash
  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

# EXAMPLE
url_string = 'http://www.radisson.com/reservation/rateSearch.do?rateSearchForm.checkinDate=11%2F02%2F2015&rateSearchForm.checkoutDate=11%2F03%2F2015&rateSearchForm.hotelCode=WIWAUWAT&rateSearchForm.hotelName=Radisson+Hotel+Milwaukee+-+West&rateSearchForm.numberRooms=1&rateSearchForm.occupancyForm%5B0%5D.numberAdults=1&rateSearchForm.occupancyForm%5B0%5D.numberChildren=0&rateSearchForm.promotionalCode=&rateSearchForm.redemptionSearch=false&rateSearchForm.travelAgentID=50154021&rateSearchForm.viewAllRates=true&iframes=http%3A%2F%2Fwww.radisson.com%2Ffacilitators.do%3FfacilitatorId%3DJACKRABBITSYSTEMS'
gets_obj = Gets.new(url_string)
necessary = gets_obj.get_params
puts necessary

byebug ; 4