Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "parse#index"
  get "matches" => "parse#matches"
  get "players_matches" => "parse#players_matches"
  get "deep_match_info" => "parse#deep_match_info"
  resources :parse_varena
end
