#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

SUCCESS_STATUS_CODE = 200
ACCEPTED_STATUS_CODE = 202
NOT_FOUND_STATUS_CODE = 404

docker_hub_username = ENV['DOCKER_HUB_USERNAME']
docker_hub_password = ENV['DOCKER_HUB_PASSWORD']
docker_hub_repository_name = ENV['DOCKER_HUB_REPOSITORY']

if docker_hub_username.nil? || docker_hub_password.nil? || docker_hub_repository_name.nil?
  warn 'Missing necessary environment variables!'
  exit 1
end

# Docker Hub login API endpoint
login_url = URI('https://hub.docker.com/v2/users/login/')

login_payload = {
  username: docker_hub_username,
  password: docker_hub_password
}

# Get the authentication token
uri = URI.parse(login_url.to_s)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
request.body = login_payload.to_json

response = http.request(request)

if response.code.to_i == SUCCESS_STATUS_CODE
  response_body = JSON.parse(response.body)
  auth_token = response_body['token']
  warn 'Successfully authenticated'
else
  warn "Error authenticating: #{response.body}"
  exit 2
end

# Check if the repository exists
check_url = URI("https://hub.docker.com/v2/repositories/#{docker_hub_username}/#{docker_hub_repository_name}/")
warn "Checking existence of repository: #{check_url}"

# GET the repository
uri = URI.parse(check_url.to_s)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri.path)

# Send the request to Docker Hub API
check_response = http.request(request)
check_response_code = check_response.code.to_i

if check_response_code == SUCCESS_STATUS_CODE
  warn "#{check_response_code}: Repository '#{docker_hub_repository_name}' exists"
elsif check_response_code == NOT_FOUND_STATUS_CODE
  warn "#{check_response_code}: Error Repository '#{docker_hub_repository_name}' not found"
  exit 2
else
  warn "#{check_response_code}: Error checking repository: #{check_response.body}"
  exit 2
end

# Delete the repository
delete_url = URI("https://hub.docker.com/v2/repositories/#{docker_hub_username}/#{docker_hub_repository_name}/")
warn "Deleting: #{delete_url}"

# Create DELETE request to remove the repository
uri = URI.parse(delete_url.to_s)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Delete.new(uri.path, { 'Authorization' => "JWT #{auth_token}" })

# Send the request to Docker Hub API
delete_response = http.request(request)

delete_response_code = delete_response.code.to_i
delete_response_body = delete_response.body

if delete_response_code == ACCEPTED_STATUS_CODE
  warn "#{delete_response_code}: Repository '#{docker_hub_repository_name}' has been deleted successfully"
else
  warn "#{delete_response_code}: Failed to delete repository: #{delete_response_body}"
  exit 2
end
