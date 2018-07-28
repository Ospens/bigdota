class ParseVarenaController < ApplicationController
  before_action :auth

  def index
    page_range = 5..6
    series = []
    @data = []
    page_range.each do |page|
      matches = @agent.get("https://ru.dotabuff.com/esports/events/254-china-dota-2-supermajor/matches?original_slug=254-china-dota-2-supermajor&page=#{page}")
                .search('article')
                .search('table.recent-esports-matches').search('tbody').css('tr')
      matches.each do |tr|
        match_info = []
        check_series_link = tr.css('td')[1].search('a').first
        series_link = check_series_link ? check_series_link.attributes['href'].value : nil
        next unless series_link
        next if tr['class'] == "inactive" || series.include?(series_link)
        series.push series_link if series_link
        page_series = @agent.get("https://ru.dotabuff.com#{series_link}")

        match_table = page_series.search('section.series-matches')
        players_part = page_series.search('div.flex-container')
        # team_stats = players_info(players_part)
        team_header = match_table.search('table.table').search('thead').css('tr')
        team_1 = team_header.search('th')[4].search('a').first.attributes['href'].value
        team_2 = team_header.search('th')[5].search('a').first.attributes['href'].value

        team_table = match_table.search('table.table').search('tbody').css('tr')
        team_table.each do |tr|
          row = []
          next if tr.search('td').search('td.not-played').present?
          row.push team_1
          row.push team_2
          tr.css('td').each_with_index do |td, index|
            if index == 0
              link_match = td.search('div.match-link').search('a').first.attributes['href'].value
              map_number = td.search('div.match-link').search('a').text
              row.push link_match
              row.push map_number.split(":")[0].split(" ")[1]
            elsif index == 1
              row.push (td.search('a.team-link').first.attributes['href'].value == team_1)
            elsif index == 2
              scores = td.search('small').search('span.score-line')
              sum = scores.search('span')[1].text.split(": ")[1].to_i + scores.search('span')[3].text.split(": ")[1].to_i
              row.push sum
            elsif index == 3
              duration = td.search('div').first.text.gsub(':', '.')
              if duration.length > 5
                row.push (60*duration[0].to_i + duration[2..3].to_i).to_s + duration[4..6]
              else
                row.push duration
              end
            elsif index == 4
              row.push td.search('span.the-radiant').text == 'Силы Света'
              row.push td.search('acronym').present?
            end
          end
          #team_stats.each do |el|
          #  el.each { |e| row.push e }             
          #end
          @data.push row
        end
      end
    end
  end

  private

  def players_info(container)
    team_player_info = []
    container.search('section.series-team').each do |section|
      team = []
      player_list = section.search('div.players').search('table').search('tbody').css('tr')
      player_list.each_with_index do |tr, i|
        break if i > 4
        player_link = tr.search('td.player-name').search('a').first.attributes['href'].value
        p player_link
        team.push player_link
        player_page = @agent.get("https://ru.dotabuff.com#{player_link}/matches?date=month")
        avg_duration = []
        kda = []
        stat = []
        player_page.search('div.col-8').search('table.table-striped')
                   .search('tbody').css('tr').each do |tr|
          tr.css('td').each_with_index do |td, i|
            next if [0, 1, 2, 3, 6].include?(i)
            if i == 4
              duration = td.text.gsub(':', '.')
              if duration.length > 5
                avg_duration.push ((60*duration[0].to_i + duration[2..3].to_i).to_s + duration[4..6]).to_f
              else
                avg_duration.push duration.to_f
              end
            elsif i == 5
              temp = []
              td.search('span.kda-record').search('span.value').each do |span|
                temp.push span.text.to_i
              end
              kda.push temp
            end
          end
        end

        player_page.search('div.col-4').search('table.table-striped')
                   .search('tbody').first.css('tr').css('td').each_with_index do |td, i|
          next if i == 0
          val = td.text.to_f
          val = (val / 100.0) if i == 2
          stat.push val
        end
        team.push avg_duration
        team.push kda
        team.push stat
      end
      team_player_info.push team
    end
    team_player_info
  end

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end
end
