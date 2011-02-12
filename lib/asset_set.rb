require 'digest/md5'
require 'json'
require 'net/http'
require 'uri'

class AssetSet
  
  @@compiler_api_url   = "http://closure-compiler.appspot.com/compile"
  @@compiled_directory = "public/compiled"

  
  attr_accessor :name, :files, :file_list, :js, :css, :sort, :assets
  
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
  
  def compiled_file(filetype = :js)
    File.join(@@compiled_directory, name + "." + filetype.to_s )
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
  
  def compile
    res = Net::HTTP.post_form( URI.parse(@@compiler_api_url),
            {
              'js_code'           => concatenate,
              'compilation_level' => compilation_level, 
              'output_format' => 'json',
              'output_info'   => 'compiled_code'
            })
    res = JSON.parse( res.body )
    
    f = File.open(compiled_file,"w+")
    f.puts res["compiledCode"]
    f.close
    
    return File.read(compiled_file)
  end
  
end
