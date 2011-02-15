require 'rubygems'
require 'sinatra'
require 'json'
require "yaml"
require 'digest/md5'
require 'json'
require 'net/http'
require 'uri'
require 'open-uri'
require 'pathname'
require 'ostruct'
 
require 'require_all'


DEV=false
YAML_FILE = 'assets.yml'


require_all 'lib'