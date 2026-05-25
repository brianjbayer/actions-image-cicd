#!/usr/bin/env ruby
# frozen_string_literal: true

require 'octokit'

# Required inputs
github_access_token = ENV.fetch('GITHUB_TOKEN')
owner_repository = ENV.fetch('GITHUB_OWNER_REPOSITORY')
merge_commit = ENV.fetch('MERGE_COMMIT')

# Authorize
client = Octokit::Client.new(access_token: github_access_token)

# List pull requests associated with the commit SHA
puts "Searching Repository #{owner_repository} for merge commit #{merge_commit}"
# This endpoint identifies the PR that was merged by this specific SHA
prs = client.commit_pulls(owner_repository, merge_commit)

# Expect there to be at least one
matching_prs = prs.select { |pr| pr.merge_commit_sha == merge_commit }
raise "No PR found where this SHA is the merge commit!" if matching_prs.empty?

# And only one
if matching_prs.size > 1
  pr_numbers = matching_prs.map(&:number).join(', ')
  raise "More than one PR with merge commit: Found PR #s [#{pr_numbers}]!"
end
target_pr = matching_prs.first

# PR Attributes
pr_info = {
  number: target_pr.number,
  title: target_pr.title,
  url: target_pr.html_url,
  branch: target_pr.head.ref,
  last_commit_on_branch: target_pr.head.sha,
  base_branch: target_pr.base.ref,
  last_commit_on_base: target_pr.base.sha
}

# Write to Github Actions output
File.open(ENV.fetch('GITHUB_OUTPUT'), 'a') do |f|
  pr_info.each do |key, value|
    # Transform ruby_underscore to action-dash ("last_commit" to "last-commit")
    github_key = key.to_s.tr('_', '-')
    set_github_action_output = "#{github_key}=#{value}"
    puts set_github_action_output
    f.puts(set_github_action_output)
  end
end
