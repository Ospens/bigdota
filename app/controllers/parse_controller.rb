class ParseController < ApplicationController
  before_action :auth, only: :index

  def index
    @html = @agent.get('https://ru.dotabuff.com/esports/teams/1883502-virtus-pro/players?date=year&league_tier=premium')
                  .search('article.r-tabbed-table')
                  .search('table').search('tbody').css('tr')
    @html.each_with_index do |tr, i|
      tr.css('td').each_with_index do |td, index|
        if index == 1 
          p td.search('.esports-player').first.attributes['href'].value
        else
          p td["data-value"]
        end
      end
        p i
    end
  end

  private

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end
end
