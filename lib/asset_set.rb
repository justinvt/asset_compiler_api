require 'digest/md5'
require 'json'
require 'net/http'
require 'uri'
require 'lib/upload/s3.rb'

class AssetSet
  
  @@compiler_api_url   = "http://closure-compiler.appspot.com/compile"
  @@compiled_directory = "public/compiled"

  
  attr_accessor :name, :md5, :compiled_code, :files, :file_list, :js, :css, :sort, :assets, :url
  
  def initialize(name, *files)
    @name = name
    @file_list = {}
    @files = files.to_a.flatten || []
    @assets = files.to_a.flatten || []
    @sort  = 0
    
  end
  
  def catted_file(filetype = :js)
    File.join(@@compiled_directory, name + ".cat." + filetype.to_s )
  end
  
  
  def compiled_file(options={})
    options[:filetype] ||= :js
    File.join( @@compiled_directory, [ name, md5, options[:filetype].to_s].join(".") )
  end
  
  def append(file_hash)
    file = file_hash.is_a?(String) ? {:url => file_hash} : file_hash
    asset = Asset.new(file_hash)
    assets << asset
    files << asset.path
    file_list[asset.ext] ||= []
    file_list[asset.ext] << asset
  end
  
  def concatenate
    f = File.open(catted_file,"w+")
    f.puts assets.uniq.map{|a| a.contents }.join("\n")
    f.close
    return open(catted_file).read
  end
  
  def compilation_level
    "WHITESPACE_ONLY"
  end
  
  def compiler_response
     res = Net::HTTP.post_form( URI.parse(@@compiler_api_url),
              {
                'js_code'           => concatenate,
                'compilation_level' => compilation_level, 
                'output_format' => 'json',
                'output_info'   => 'compiled_code'
              })

      res = JSON.parse( res.body )
  end
  
  def compile
    
    @compiled_code = compiler_response["compiledCode"]
    @md5 = Digest::MD5.hexdigest(@compiled_code)
    
    f = File.open(compiled_file,"w+")
    f.puts @compiled_code
    f.close
    
    return File.read(compiled_file)
  end
  
  def upload
    object = Upload::AWSS3.upload(:file => compiled_file)
    @url = object.url
  end
  
end
