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
/matches/4011614021
/matches/4011560072
/matches/4011358279
/matches/4011325268
/matches/4010064308
/matches/4010019430
/matches/4009963380
/matches/4009907496
/matches/4009840812
/matches/4009777225
/matches/4009718038
/matches/4009588315
/matches/4009554135
/matches/4008459612
/matches/4008391977
/matches/4008331079
/matches/4008289551
/matches/4008235072
/matches/4008184917
/matches/4008149783
/matches/4008116250
/matches/4008082709
/matches/4007993673
/matches/4007969101
/matches/4007404122
/matches/4007322300
/matches/4006958998
/matches/4006710923
/matches/4006646949
/matches/4006603880
/matches/4006341346
/matches/4006307268
/matches/4006232970
/matches/4006198957
/matches/4016944173
/matches/4016797604
/matches/4016723925
/matches/4016549662
/matches/4016436133
/matches/4015472354
/matches/4015385623
/matches/4015296595
/matches/4015211082
/matches/4015112122
/matches/4014931986
/matches/4014887448
/matches/4014805833
/matches/4013794261
/matches/4013651448
/matches/4013547645
/matches/4013483533
/matches/4013375770
/matches/4010601156
/matches/4010452117
/matches/4010222407
/matches/4010152452
/matches/4010084222
/matches/4008950768
/matches/4008841583
/matches/4008759349
/matches/4008666445
/matches/4007490319
/matches/4007373138
/matches/4007278271
/matches/4007197912
/matches/4007106841
/matches/4006965978
/matches/4006747648
/matches/4006667255
/matches/4006608756
/matches/4005688113
/matches/4005614390
/matches/4005541369
/matches/4017040489
/matches/4010378453
/matches/4010295178
/matches/4006729472
/matches/4006631970
/matches/4006548514
/matches/4017104366
/matches/4017006579
/matches/4016866708
/matches/4016791936
/matches/4016684770
/matches/4016164992
/matches/4016124761
/matches/4008201144
/matches/4008145067
/matches/4008113635
/matches/4008092263
/matches/4008053062
/matches/4008021543
/matches/4007997531
/matches/4007972523
/matches/4007940659
/matches/4007894665
/matches/4007843220
/matches/4007807304
/matches/4007758218
/matches/4007696672
/matches/4007655639
/matches/4007569574
/matches/4007521295
/matches/4007426270
/matches/4007349527
/matches/4007250947
/matches/4007177017
/matches/4007050642
/matches/4006943296
/matches/4006885792
/matches/4013726749
/matches/4013669752
/matches/4012870750
/matches/4012851661
/matches/4012827992
/matches/4011283088
/matches/4017016682
/matches/4016913755
/matches/4006362423
/matches/4006312175
/matches/4006210827
/matches/4015467036
/matches/4015393902
/matches/4015321368
/matches/4015242355
/matches/4015139621
/matches/4013914863
/matches/4013849296
/matches/4013783289
/matches/4013699931
/matches/4007289141
/matches/4007209167
/matches/4007056910
/matches/4017002497
/matches/4016456093
/matches/4016350714
/matches/4016173512
/matches/4016134093
/matches/4016065957
/matches/4013692619
/matches/4013566432
/matches/4007188235
/matches/4007077763
/matches/4007007426
/matches/4016989006
/matches/4015353530
/matches/4015280440
/matches/4013466624
/matches/4012047217
/matches/4010460065
/matches/4010391071
/matches/4008819939
/matches/4006922697
/matches/4006796168
/matches/4006730769
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
    team_page = @agent.get("https://ru.dotabuff.com#{link}/players?date=year&league_tier=premium")
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
    main_page = @agent.get("https://www.dotabuff.com#{link}?date=year&league_tier=premium")
                  .search('div.col-4').search('article').search('table')
                  .search('tbody').first.css('tr')
    main_page.each_with_index do |tr, i|
      tr.css('td').each_with_index do |td, index|
        next if index == 0
        team_stat.push td["data-value"]
      end
    end
    @team.push 
  end

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end
end
