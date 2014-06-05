#!/usr/bin/env ruby

# Find or delete files in S3 older than a given age and matching a pattern

require 'rubygems'
require 'time'
require 'optparse'
require 'yaml'
begin 
  require 'fog'
rescue
  puts "Missing the fog gem ! Try sudo gem install fog"
end

class S3Cleaner
  def self.parse(args)
    options = {}
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"
      opts.separator ""
      options[:delete] = false
      opts.on("-d","--delete","Actually do a delete. If not specified , just list the keys found that match") do
        options[:delete] = true
      end
      opts.on("-c","--config FILE","Read options from file") do |c|
        options[:config] = c
      end
      opts.on_tail("-h","--help","Show this message") do
        puts opts
        exit
      end
    end
    begin
      opts.parse(args)
      raise OptionParser::MissingArgument, "-c no config file specified" if not options[:config]
    rescue SystemExit
      exit
    rescue OptionParser::ParseError
      puts "Oops... #{$!}"
      puts opts
      exit
    end
    options
  end

  # Get S3 Connection 

  def self.get_s3connection(aws_access_key,aws_secret_key)
    connection = Fog::Storage.new({
      :provider => 'AWS',
      :aws_access_key_id => aws_access_key,
      :aws_secret_access_key => aws_secret_key,
      :path_style => true
    })
  end

  # Find files in a bucket specif to a pattern

  #  <Fog::Storage::AWS::File
  #             key="test.txt",
  #             cache_control=nil,
  #             content_disposition=nil,
  #             content_encoding=nil,
  #             content_length=28,
  #             content_md5=nil,
  #             content_type=nil,
  #             etag="32b10865eeb075b3d8fdbd8918741782",
  #             expires=nil,
  #             last_modified=2014-04-05 06:32:57 UTC,
  #             metadata={},
  #             owner={:display_name=>nil, :id=>nil},
  #             storage_class="STANDARD",
  #             encryption=nil,
  #             version=nil
  #           >,
  #

  # Get a list of files to delete

  def self.files_to_delete(connection,bucket,prop)
    fd = []
    now = Time.now.utc
    connection.directories.get(bucket, prefix:prop["REGEX"]).files.map do |file|
      age = (( now - file.last_modified).to_i)/(3600*24)
      maxage = prop["AGE"].scan(/\d+/)[0].to_i
      if age > maxage
        fd << file.key
      end
    end
    return fd
  end



  def self.run(args)
    opts = parse(args)
    config = opts[:config]
    if File.exists? config
      puts "Loading bucket configuration and AWS credentials from #{config}"
      fp = YAML::load(File.open(config))
      buckets= fp["BUCKETS"]
      aws_access_key = fp["AWS_ACCESS_KEY_ID"]
      aws_secret_key = fp["AWS_SECRET_ACCESS_KEY"]
    else
      puts "- Config file #{config} not found, nothing todo here"
      exit 1
    end

    raise "No buckets specified" if not buckets
    raise "No AWS ACCESS KEY ID specified" if not aws_access_key
    raise "No AWS SECRET ACCESS KEY specified" if not aws_secret_key

    connection = get_s3connection(aws_access_key,aws_secret_key)
    buckets.each do |bucket,prop|
    filesToDelete = files_to_delete(connection,bucket,prop)
      if opts[:delete]
        puts "==Deleting " + filesToDelete.count.to_s + " objects in #{bucket} =="
        connection.delete_multiple_objects(bucket,filesToDelete) if not filesToDelete.empty?
      else
        puts "==Below are the list of objects present in #{bucket}==\n\n"
        puts " == Total Number of File ==  " + filesToDelete.count.to_s + "\n"
        puts filesToDelete.join("\n") if not filesToDelete.empty?
      end
    end
  end
end

S3Cleaner.run(ARGV)
