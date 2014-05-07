#!/usr/bin/env ruby

# Find or delete files in S3 older than a given age and matching a pattern

require 'rubygems'
require 'time'
require 'optparse'
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
      opts.on("-k","--key AWS_ACCESS_KEY", "AWS ACCESS KEY ID") do |k|
        options[:key] = k
      end
      opts.on("-s","--secret AWS_SECRET_KEY", "A SECRET ACCESS KEY") do |s|
      options[:secret] = s
      end
      opts.on("-a" ,"--maxage MAX_AGE","MAX_AGE in days") do |a|
        options[:maxage] = a
      end
      options[:regex] = ''
      opts.on("-r","--regex REGEX","Only consider keys matching this REGEX") do |r|
        options[:regex] = r
      end
      opts.on("-b","--bucket BUCKET","Search for keys in a specific bcuket") do |b|
        options[:bucket] = b
      end
      options[:delete] = false
      opts.on("-d","--delete","Actually do a delete. If not specified , just list the keys found that match") do
        options[:delete] = true
      end
      opts.on_tail("-h","--help","Show this message") do
        puts opts
        exit
      end
    end
    begin
      opts.parse(args)
      raise OptionParser::MissingArgument, "-k , no AWS_ACCESS_KEY specified" if not options[:key]
      raise OptionParser::MissingArgument, "-s , no AWS_SECRET_KEY specified" if not options[:secret]
      raise OptionParser::MissingArgument, "-a , no MAX_AGE specified" if not options[:maxage]
      raise OptionParser::MissingArgument, "-b , no BUCKET name specified" if not options[:bucket]
    rescue SystemExit
      exit
    rescue OptionParser::ParseError
      puts "Oops... #{$!}"
      #puts "Error " + e, "#{__FILE__} -h for options"
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

  def self.list_files(connection,bucket,prefix)
    files = {}
    connection.directories.get(bucket, prefix: prefix).files.map do |file|
      files[file.key] = file.last_modified
    end
    return files
  end

  # Get a list of files to delete

  def self.files_to_delete(files,maxage)
    fd = []
    now = Time.now.utc
    files.each do |name,time|
      age = ((now - time).to_i)/(3600*24)
      if age > maxage
       fd << name
      end
    end
    return fd
  end


  def self.run(args)
    opts = parse(args)
    bucket_name = opts[:bucket]
    connection = get_s3connection(opts[:key],opts[:secret])
    files = list_files(connection,bucket_name,opts[:regex])
    maxage = opts[:maxage].scan(/\d+/)[0].to_i
    if not files.empty?
      filesToDelete =  files_to_delete(files,maxage)
      if opts[:delete]
        puts "==Deleting all the files in #{bucket_name} =="
        connection.delete_multiple_objects(bucket_name,filesToDelete) if not filesToDelete.empty?
      else
        puts "==Below is the list of files present in #{bucket_name}==\n\n"
        puts " == Total Number of File ==  " + filesToDelete.count.to_s + "\n"
        puts filesToDelete.join("\n") if not filesToDelete.empty?
      end
    else
      puts "The #{bucket_name} is empty !!"
    end
  end
end

S3Cleaner.run(ARGV)
