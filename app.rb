require 'rubygems'
require 'sinatra'
require 'json'
require 'require_all'

require_all 'lib'

@@asset_lists = {}

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
  "Saved to #{ @@asset_lists[ @list_name ].url}"
end
