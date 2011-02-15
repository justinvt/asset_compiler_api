class AssetDB
  
  @@db_yaml_filename = YAML_FILE || 'assets.yml'
  
  attr_accessor :db_filename, :yaml_db, :asset_sets
  
  def initialize(options={})
    @db_filename = options[:yaml_filename] || @@db_yaml_filename
    @yaml_db = YAML::load( open(@db_filename).read )
    @asset_sets = {}
    @yaml_db.each_pair do |k,v|
      append_set(k, :files => v[:files])
    end
  end
  
  def append_set(name, options={})
    @asset_sets[name.to_sym] = AssetSet.new(name.to_s, options)
  end
  
  def superset(name, options={})
    puts "Creating superset from #{options[:from].join(',')}"
    files = options[:from].map{|s| @asset_sets[s.to_sym].files }.flatten

    return append_set(name, :files => files,  :from => options[:from])
  end
  
  def content
    output = {}
    @asset_sets.each_pair do |k,v|
      output[k] = v.to_tiny_yaml
    end
    YAML::dump( output  )
  end
  
  def save
    f = File.open(db_filename, "w+")
    f.puts content
    f.close
  end
  
end