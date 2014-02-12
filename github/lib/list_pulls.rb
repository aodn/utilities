#!/usr/bin/env ruby

require 'colorize'
require 'octokit'
require 'trollop'

if (!ENV['GITHUB_ACCESS_TOKEN'])
  abort("Environment variable 'GITHUB_ACCESS_TOKEN' must be set (see 'https://help.github.com/articles/creating-an-access-token-for-command-line-use').")
end

opts = Trollop::options do
  opt :short, "Print in short mode"
end

def print_long_format(repo_name, pull)
  print "Pull request: "
  puts pull.title.green

  print "repo: "
  puts repo_name.green

  print "created at: "
  puts pull.created_at

  print "url: "
  puts pull.rels[:html].href.blue

  print "description: "
  puts "#{pull.body}\n\n"
end

def print_short_format(repo_name, pull)
  print pull.created_at
  puts " #{pull.rels[:html].href}".blue
end


client = Octokit::Client.new :access_token => ENV['GITHUB_ACCESS_TOKEN']

client.orgs.each do |org|

  client.repos(org.login).each do |repo|
    repo_name = "#{org.login}/#{repo.name}"
    pulls = client.pulls(repo_name)
    pulls.each do |pull|
      opts.short ? print_short_format(repo_name, pull) : print_long_format(repo_name, pull)
    end
  end
end
