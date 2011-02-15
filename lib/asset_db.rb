class AssetDB
  
  @@db_yaml_filename = YAML_FILE || 'assets.yml'
  
  attr_accessor :db_filename, :yaml_db, :asset_sets, :loaded_sets
  
  def initialize(options={})
    @db_filename = options[:yaml_filename] || @@db_yaml_filename
    @yaml_db = YAML::load( open(@db_filename).read )
    @asset_sets = {}
    @loaded_sets ||= []
    @yaml_db.each_pair do |k,v|
      files = load_set(k)
      append_set(k.to_sym, :files => files)
    end
  end
  
  def load_set(set_name)
    values = @yaml_db[set_name]
    files  = values.nil? ? [] : values[:files].to_a
    sets   = values.nil? ? [] : ( values[:sets].to_a - @loaded_sets )
    @loaded_sets = [ @loaded_sets, sets].flatten.uniq
    to_load = [ files, sets.map{|s| load_set(s) } ].flatten.to_a.uniq
    return to_load
  end
  
  def group(name)
    @asset_sets[name.to_sym]
  end
  
  def append_set(name, options={})
    @asset_sets[name.to_sym] = AssetSet.new(name.to_s, options)
  end
  
  def superset(name, options={})
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