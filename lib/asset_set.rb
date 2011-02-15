require 'digest/md5'
require 'json'
require 'net/http'
require 'uri'
require 'lib/upload/s3.rb'

class AssetSet
  
  @@compiler_api_url   = "http://closure-compiler.appspot.com/compile"
  @@compiled_directory = "public/compiled"
  @@default_compile_type = "WHITESPACE_ONLY"

  
  attr_accessor :name, :md5, :cat_md5, :compiled_code, :catted_code, :compile_type, :files, :file_list, :js, :css, :sort, :assets, :url, :from
  
  def initialize(name, options = {})
    puts "Initializing asset set #{name}"
    @name = name
    @sort  = 0
    @file_list = {}
    @from = options[:from] || []
    @files = options[:files].to_a.uniq.flatten || []
    @compile_type = options[:compile_type] || @@default_compile_type
    @assets = []
    puts "Appending files: " + @files.inspect
    @files.each do |f|
      puts "Appending #{f}"
      append(f)
    end
    self
  end
  
  def catted_file(filetype = :js)
    File.join(@@compiled_directory, @cat_md5 + "." + filetype.to_s )
  end
  
  def to_tiny_yaml
    {:files => files, :url => url, :md5 => md5}
  end
  
  def yaml_save(yaml_file=YAML_FILE)
    yaml_db = YAML::load( open(yaml_file).read )
    yaml = {}
    yaml[name] = to_tiny_yaml
    f = File.open(yaml_file, "w+")
    new_db = yaml_db.merge(yaml)
    f.puts YAML::dump( new_db )
    f.close
  end
  
  
  def compiled_file(options={})
    options[:filetype] ||= :js
    File.join( @@compiled_directory, [ md5, options[:filetype].to_s].join(".") )
  end
  
  def append(file_hash)
    file = file_hash.is_a?(String) ? {:url => file_hash} : file_hash
    asset = Asset.new( file )
    unless files.include?(asset.path)
      assets << asset
      files << asset.path
      file_list[asset.ext] ||= []
      file_list[asset.ext] << asset
    end
  end
  
  def concatenate
    @catted_code = assets.uniq.map{|a| a.contents }.join("\n")
    @cat_md5     = Digest::MD5.hexdigest( @catted_code )
    unless File.exist? catted_file
      f = File.open(catted_file,"w+")
      f.puts catted_content
      f.close
    end
    return open(catted_file).read
  end
  
  def compilation_level
    compile_type || @@default_compile_type
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
      if res["serverErrors"].length > 0
        res["serverErrors"].each{|e| puts "Error " + e["code"].to_s + ": " + e["error"]}
        return {"compiledCode" => ""}
      else
        return res
      end
  end
  
  def compile
    @compiled_code = compiler_response["compiledCode"]
    @md5 = Digest::MD5.hexdigest(@compiled_code)
    unless File.exist?(compiled_file)
      f = File.open(compiled_file,"w+")
      f.puts @compiled_code
      f.close
    end
    return File.read(compiled_file)
  end
  
  def upload
    @url = Upload::AWSS3.upload(:file => compiled_file).url
    yaml_save
    @url
  end
  
  def compiled_url
    if url
      url
    elsif md5
      compiled_file
    elsif cat_md5
      catted_file
    else
      concatenate
      catted_file
    end
  end
  
  def html_include_for(scripts)
    [scripts].flatten.map{|s| "<script type='text/javascript' src='#{s}'></script>" }.join("\n")
  end
  
  def html_include
    html_include_for(DEV ? files : compiled_url)
  end

end
