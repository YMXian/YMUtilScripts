#!/usr/bin/env ruby

require 'thor'
require 'fileutils'
require 'pathname'
require 'kiss_shot'

class GenService < Thor
  # Extension for KissShot
  module KissShotExt
    def objc_h_header(filename, copyright)
      objc_block_comment do
        line "#{filename}"
        line
        line "Copyright #{Time.now.year} (c) #{copyright}, All Rights Reserved."
        line
        line "Generated by GenService.rb/KissShot"
      end
      line
    end
  end

  # The create Command
  desc "create NAME", "Create a service"
  method_option :copyright, aliases: ['-c'], desc: 'Copyright information', required: true, type: :string, default: 'Ju Xian (BeiJing) Technology Co., Ltd.'
  method_option :directory, aliases: ['-d'], desc: 'Resource directory', required: true, type: :string
  method_option :prefix,    aliases: ['-p'], desc: 'Class prefix for generated classes', required: true, type: :string, default: 'YM'
  def create(name)
    raise "service name not speicifed" if name.nil?
    copyright = options['copyright']
    prefix    = options['prefix']
    directory = options['directory']
    class_name= "#{prefix}#{name}"
    FileUtils.mkdir_p directory
    raise "#{directory} is not a directory" unless File.directory? directory

    # Write the YMXXServiceBackend protocol
    File.open "#{directory}/#{class_name}Backend.h", 'w' do |f|
      content = KissShot::Spec.run do
        use KissShot::ObjC::All
        use GenService::KissShotExt

        objc_h_header "#{class_name}Backend.h", copyright
        objc_import_d "Foundation/Foundation.h"
        objc_protocol "#{class_name}Backend" do
          objc_protocol_required
        end
      end
      f.write content
    end

    # Write the YMXXServiceBackendImpl.h
    File.open "#{directory}/#{class_name}BackendImpl.h", 'w' do |f|
      content = KissShot::Spec.run do
        use KissShot::ObjC::All
        use GenService::KissShotExt

        objc_h_header "#{class_name}BackendImpl.h", copyright
        objc_import_d "YMFoundation/YMFoundation.h"
        objc_import_q "#{class_name}Backend.h"
        line
        objc_interface "#{class_name}BackendImpl", "YMLoaderProxy", ["#{class_name}Backend"] do
        end
      end
      f.write content
    end


    # Write the YMXXServiceBackendImpl.m
    File.open "#{directory}/#{class_name}BackendImpl.m", 'w' do |f|
      content = KissShot::Spec.run do
        use KissShot::ObjC::All
        use GenService::KissShotExt

        objc_h_header "#{class_name}BackendImpl.m", copyright
        line
        objc_import_q "#{class_name}BackendImpl.h"
        line
        line "SUPPRESS_START"
        line "SUPPRESS_PROTOCOL"
        line "SUPPRESS_OBJC_PROTOCOL_PROPERTY_SYNTHESIS"
        line
        objc_implementation "#{class_name}BackendImpl" do
          line
          objc_method false, :void, :build do
            line "[super build];"
          end
          line
        end
        line
        line "SUPPRESS_END"
      end
      f.write content
    end


    # Write the YMXXService.h
    File.open "#{directory}/#{class_name}.h", 'w' do |f|
      content = KissShot::Spec.run do
        use KissShot::ObjC::All
        use GenService::KissShotExt

        objc_h_header "#{class_name}.h", copyright
        objc_import_d "Foundation/Foundation.h"
        objc_import_q "#{class_name}Backend.h"
        objc_import_q "#{prefix}BaseService.h"
        line
        line "#define #{name} [#{class_name} shared]"
        line
        objc_interface "#{class_name}", "YMBaseService" do
          line
          objc_property "backend", ["id<#{class_name}Backend>", "__nonnull"]
          line
        end
      end
      f.write content
    end

    # Write the YMXXService.m
    File.open "#{directory}/#{class_name}.m", 'w' do |f|
      content = KissShot::Spec.run do
        use KissShot::ObjC::All
        use GenService::KissShotExt

        objc_h_header "#{class_name}.m", copyright
        objc_import_q "#{class_name}.h"
        objc_import_q "#{class_name}BackendImpl.h"
        line

        objc_implementation "#{class_name}" do
          line
          objc_method true, :void, :staticInit do
            line "[super staticInit];"
          end
          line
          objc_method false, :void, :syncInit do
            line "[super syncInit];"
            line "self.backend = [[#{class_name}BackendImpl alloc] init];"
          end
          line
          objc_method false, :void, :asyncInit do
            line "[super asyncInit];"
          end
          line
        end
      end
      f.write content
    end
  end
end

GenService.start
