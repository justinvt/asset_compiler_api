require 'rubygems'
require 'sinatra'
require 'json'
require 'require_all'

require_all 'lib'

#a = Asset.new( :url => "http://d3g0gp89917ko0.cloudfront.net/v--5fd8b135436a/common--javascript/init.combined.js")
@@asset_lists = {}

set :public, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'


post '/append/:filename' do
  list_name = params[:filename]
  url       = params[:uri]
  
  asset     = Asset.new( :url => url )
  
  @@asset_lists ||= {}
  @@asset_lists[ list_name ] ||= AssetSet.new( list_name )
  @@asset_lists[ list_name ].append( asset.for_set )
  
  "Appended #{asset.contents.size} bytes from #{url} - #{@@asset_lists.inspect}" 
end

get '/append/:filename' do
  list_name = params[:filename]
  url       = params[:uri]
  
  asset     = Asset.new( :url => url )
  
  @@asset_lists ||= {}
  @@asset_lists[ list_name ] ||= AssetSet.new( list_name )
  @@asset_lists[ list_name ].append( asset.for_set )
  
  "Appended #{asset.contents.size} bytes from #{url} - #{@@asset_lists.inspect}" 
end


post '/compile/:filename' do
  list_name = params[:filename]
  @@asset_lists ||= {}
  @@asset_lists[ list_name ] ||= AssetSet.new( list_name )
  @@asset_lists[ list_name ].compile
  "Compiled #{ @@asset_lists[ list_name ].compiled_file } - #{@@asset_lists.inspect}"
end
