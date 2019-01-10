class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: :create

#   def create
#     github = GithubService.new
#     session[:token] = github.authenticate!(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], params[:code])
#     redirect_to root_path
#   end
# end

  def create
    response = Faraday.post "https://github.com/login/oauth/access_token", {client_id: ENV["CLIENT_ID"], client_secret: ENV["CLIENT_SECRET"],code: params[:code]}, {'Accept' => 'application/json'}
    access_hash = JSON.parse(response.body)
    session[:token] = access_hash["access_token"]

    user_response = Faraday.get "https://api.github.com/user", {}, {'Authorization' => "token #{session[:token]}", 'Accept' => 'application/json'}
    user_json = JSON.parse(user_response.body)
    session[:username] = user_json["login"]

    redirect_to '/'
  end
end