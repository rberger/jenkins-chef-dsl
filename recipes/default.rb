#
# Cookbook Name:: jenkins-chef-dsl
# Recipe:: default
#

include_recipe 'chef-sugar::default'
node.set['jenkins']['master']['install_method'] = 'war'
node.set['jenkins']['master']['version'] = '1.555'
node.set['jenkins']['master']['source'] = "#{node['jenkins']['master']['mirror']}/war/#{node['jenkins']['master']['version']}/jenkins.war"
include_recipe 'jenkins::master'

# Plugins need to be installed before adding auth to the API.
include_recipe 'jenkins-chef-dsl::plugins'
include_recipe 'jenkins-chef-dsl::auth'
package 'git'

# Initial jenkinds-dsl-bootstrap job
#  This job will be the only job created by hand and will create all other jobs.
#  In this example, we just have the jobs staticly defined in a xml file with a
#  DSL Groovy script. In practice you would specify a Git repo and build poll/webhook that.
# Currently 'jenkins_job' takes a file on the file system. In the future it may
#  take a template, etc.
cookbook_file "#{Chef::Config[:file_cache_path]}/jenkins-job-DSL-bootstrap.xml" do
  source 'jenkins-job-DSL-bootstrap.xml'
end

xml = File.join(Chef::Config[:file_cache_path], 'jenkins-job-DSL-bootstrap.xml')
jenkins_job 'jenkins-job-DSL-bootstrap' do
  config xml
end
