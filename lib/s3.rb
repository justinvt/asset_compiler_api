require "s3"

module Upload
  
  module S3
    
    def service(options={})
      @@service = S3::Service.new(:access_key_id => options[:access_key] || ENV["ec2_access_key"],
                                :secret_access_key => options[:secret_key] || ENV["ec2_secret_key"])
    end
                          
                          
    def upload(options={})
      bucket = service.buckets.find( options[:bucket] || @@bucket )
      filename = options[:file]
      asset = bucket.objects.build(filename)
      new_object.content = open(filename)
      new_object.save
    end

  end
  
end
