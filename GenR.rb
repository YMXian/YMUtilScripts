#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'thor'
require 'fileutils'
require 'pathname'
require 'kiss_shot'

class GenR < Thor
  desc "create", "Create a resource file R."
  method_option :directory, aliases: ['-d'], desc: 'Resource directory', required: true, type: :string
  method_option :target,    aliases: ['-t'], desc: 'Target file, will append .h, .m for Obj-C', required: true, type: :string
  method_option :prefix,    aliases: ['-p'], desc: 'Class prefix for generated classes', required: true, type: :string, default: 'YM'
  def create
    directory = File.expand_path options[:directory], Dir.pwd
    target    = File.expand_path options[:target],    Dir.pwd
    prefix    = options[:prefix].upcase

    all_images = []

    # Get all xcassets
    Dir["#{directory}/**/*.xcassets"].each do |asset_folder|
      asset_path = Pathname.new asset_folder
      Dir["#{asset_folder}/**/*.imageset"].each do |image_folder|
        raise "#{image_folder} is not a directory" unless File.directory? image_folder
        full_query_path     = File.expand_path "../#{File.basename(image_folder, ".*")}", image_folder
        relative_query_path = Pathname.new(full_query_path).relative_path_from(asset_path).to_s
        all_images << relative_query_path
      end
    end

  end
end

GenR.start
