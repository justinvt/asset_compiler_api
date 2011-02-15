require 'rubygems'
require 'sinatra'
require 'json'
require "yaml"
 
require 'require_all'


DEV=true
YAML_FILE = 'assets.yml'
@@asset_yml_filename = YAML_FILE
@@asset_lists = {}

require_all 'lib'

@@asset_db = AssetDB.new(:yaml_filename => @@asset_yml_filename)

@@new_set = @@asset_db.superset("geo", :from => [:jt, :justin])

puts @@new_set.html_include

set :public, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'


def get_params
  @list_name = params[:filename]
  @url       = params[:uri]
  
  @asset     = Asset.new( :url => @url )
  
  @@asset_lists ||= {}
  @@asset_lists[ @list_name ] ||= AssetSet.new( @list_name )
end


post '/append/:filename' do

  get_params
  @@asset_lists[ @list_name ].append( @asset.for_set )
  
  "Appended #{@asset.contents.size} bytes from #{@url} - #{@@asset_lists.inspect}" 
end

get '/append/:filename' do

  get_params
  @@asset_lists[ list_name ].append( @asset.for_set )
  
  "Appended #{@asset.contents.size} bytes from #{@url} - #{@@asset_lists.inspect}" 
end


post '/compile/:filename' do

  get_params
  @@asset_lists[ @list_name ].compile
  "Compiled #{ @@asset_lists[ @list_name ].compiled_file } - #{@@asset_lists.inspect}"
end

post '/save/:filename' do

  get_params
  @@asset_lists[ @list_name ].upload
  @@asset_lists[ @list_name ].yaml_save(@@asset_yml_filename)
  "Saved to #{ @@asset_lists[ @list_name ].url}"
end
