class ParseController < ApplicationController
  before_action :auth, only: [:index, :matches, :players_matches, :deep_match_info]

  def index
    @teams = []
    team_links = []
    team_list = @agent.get('https://ru.dotabuff.com/esports/events/254-china-dota-2-supermajor/teams')
                  .search('article.r-desktop-tabs')
                  .search('table').search('tbody').css('tr')
    team_list.each do |tr|
      tr.css('td').each_with_index do |td, index|
        break unless index == 0
          team_links.push td.search('.esports-team').first.attributes['href'].value
      end
    end
    team_links.each do |link|
      @teams.push team_list(link)
    end
  end

  def matches
    page_range = 21..50
    @all_matches = []
    page_range.each do |page|
      matches = @agent.get("https://ru.dotabuff.com/esports/matches?page=#{page}")
                .search('article')
                .search('table.recent-esports-matches').search('tbody').css('tr')
      matches.each do |tr|
        match_info = []
        next if tr['class'] == "inactive"
        tr.css('td').each_with_index do |td, index|
          next if index == 0 || index == 1
          if index == 2
            match_info.push td.search('a').first.attributes['href'].value
          elsif index == 3
            match_info.push td.search('.block').first.text
          elsif index == 4
            match_info.push td.css('span').first['class'] == 'radiant'
            match_info.push td.search('.team-text-full').first.text
          elsif index == 5
            match_info.push td.search('.team-text-full').first.text
          elsif index == 7
            duration = td.children.first.text.gsub(':', '.')
            if duration.length > 5
               match_info.push (60*duration[0].to_i + duration[2..3].to_i).to_s + duration[4..6]
            else
               match_info.push duration
            end
          end
        end
        @all_matches.push match_info
      end
    end
  end

  def players_matches 
    players_list = %i[
    ].uniq
    @all_matches = []
    players_list.each do |page|
      matches = @agent.get("#{page}/matches?date=week&skill_bracket=very_high_skill&enhance=overview")
                .search('section')
                .search('table')[1].search('tbody').css('tr')
      matches.each do |tr|
        match_info = []
        next if tr['class'] == "inactive"
        tr.css('td').each_with_index do |td, index|
          next if index == 1 || index == 2 || index == 4 || index > 5
          if index == 0
            match_info.push td.search('div').search('a').first.attributes['href'].value
          elsif index == 3
            match_info.push td.search('a').first.attributes['href'].value
          elsif index == 5
            duration = td.children.first.text.gsub(':', '.')
            if duration.length > 5
               match_info.push (60*duration[0].to_i + duration[2..3].to_i).to_s + duration[4..6]
            else
               match_info.push duration
            end
          end
        end
        @all_matches.push match_info
      end
    end
  end 

  def deep_match_info
    @all_info = []
    players_list = %i[

    ].uniq
    players_list.each do |link|
      p link
      team_info = []
      page = @agent.get("https://ru.dotabuff.com#{link}")
      next if !page.search('td.tf-fa').empty?
      team_info.push link
      team_info.push page.search('div.match-result')
                         .first.attributes['class'].value.include? 'radiant' 
      duration = page.search('span.duration').text.gsub(':', '.')
      if duration.length > 5
          team_info.push (60*duration[0].to_i + duration[2..3].to_i).to_s + duration[4..6]
      else
          team_info.push duration
      end
      team_info.push page.search('span.the-radiant').text
      team_info.push page.search('span.the-dire').text
      all_table = page.search('div.team-results')
      radiant_table = all_table.search('section.radiant').search('tbody').css('tr')
      radiant_table.each do |tr|
        next if tr['class'] == "inactive"
        tr.css('td').each_with_index do |td, index|
          next if [1, 2, 8, 11, 16].include? index
          if index == 0
            team_info.push td.search('div').search('a').first.attributes['href'].value.gsub('/heroes/', '')
          elsif [3, 4, 5, 7, 9, 10, 12, 13, 15].include? index
            val = td.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          elsif [6].include? index
            net = td.search('acronym').first.text
            net = net.include?('k') ? (net.chomp('k').to_f * 1000) : net
            team_info.push net
          elsif [14].include? index
            val = td.search('span').first.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          end
        end
      end
      radiant_total = all_table.search('section.radiant').search('tfoot').css('tr')
      radiant_total.each do |tr|
        next if tr['class'] == "inactive"
        tr.css('td').each_with_index do |td, index|
          next if [0, 1, 2, 8, 11, 16].include? index
          if [3, 4, 5, 7, 9, 10, 12, 13, 15].include? index
            val = td.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          elsif [6].include? index
            net = td.search('acronym').first.text
            net = net.include?('k') ? (net.chomp('k').to_f * 1000) : net
            team_info.push net
          elsif [14].include? index
            val = td.search('span').first.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          end
        end
      end
      dire_table = all_table.search('section.dire').search('tbody').css('tr')
      dire_table.each do |tr|
        next if tr['class'] == "inactive"
        tr.css('td').each_with_index do |td, index|
          next if [1, 2, 8, 11, 16].include? index
          if index == 0
            team_info.push td.search('div').search('a').first.attributes['href'].value.gsub('/heroes/', '')
          elsif [3, 4, 5, 7, 9, 10, 12, 13, 15].include? index
            val = td.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          elsif [6].include? index
            net = td.search('acronym').first.text
            net = net.include?('k') ? (net.chomp('k').to_f * 1000) : net
            team_info.push net
          elsif [14].include? index
            val = td.search('span').first.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          end
        end
      end
      dire_total = all_table.search('section.dire').search('tfoot').css('tr')
      dire_total.each do |tr|
        next if tr['class'] == "inactive"
        tr.css('td').each_with_index do |td, index|
          next if [0, 1, 2, 8, 11, 16].include? index
          if [3, 4, 5, 7, 9, 10, 12, 13, 15].include? index
            val = td.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          elsif [6].include? index
            net = td.search('acronym').first.text
            net = net.include?('k') ? (net.chomp('k').to_f * 1000) : net
            team_info.push net
          elsif [14].include? index
            val = td.search('span').first.text
            val = val.include?('k') ? (val.chomp('k').to_f * 1000) : val
            team_info.push val
          end
        end
      end
      @all_info.push team_info
    end
  end

  private

  def team_list(link)
    @team = []
    @team.push [link] 
    team_page = @agent.get("https://ru.dotabuff.com#{link}/players?date=3month&league_tier=premium")
                  .search('article.r-tabbed-table')
                  .search('table').search('tbody').css('tr')
    team_page.each_with_index do |tr, i|
      break if i > 4
      player = []
      tr.css('td').each_with_index do |td, index|
        next if index == 0
        if index == 1 
          player.push  td.search('.esports-player').first.attributes['href'].value
        else
          player.push  td["data-value"].to_s.gsub('.', ',')
        end
      end
      @team.push player
    end
    team_stat = ['team stat']
    main_page = @agent.get("https://www.dotabuff.com#{link}?date=3month&league_tier=premium")
                  .search('div.col-4').search('article').search('table')
                  .search('tbody').first.css('tr')
    main_page.each_with_index do |tr, i|
      tr.css('td').each_with_index do |td, index|
        next if index == 0
        team_stat.push td["data-value"]
      end
    end
    matches_duration = []
    matches_page = @agent.get("https://www.dotabuff.com#{link}/matches?date=3month&league_tier=premium")
                  .search('div.content-inner').search('article').search('table.recent-esports-matches')
                  .search('tbody').first
    if matches_page
      matches_page = matches_page.css('tr')
      matches_page.each_with_index do |tr, i|
        tr.css('td').each_with_index do |td, index|
          next if index != 3
          duration = td.text.to_s.gsub(':', '.')
          if duration.length > 5
            matches_duration.push ((60*duration[0].to_i + duration[2..3].to_i).to_s + duration[4..6]).to_f
          else
            matches_duration.push duration.to_f
          end
        end
      end
    end
    team_stat.push matches_duration
    @team.push team_stat
  end

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end
end
