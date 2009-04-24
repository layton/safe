require "aws/s3"
require 'fileutils'

require 'tempfile'
require 'extensions/mktmpdir'

require 'astrails/safe/tmp_file'

require 'astrails/safe/config/node'
require 'astrails/safe/config/builder'

require 'astrails/safe/stream'

require 'astrails/safe/backup'

require 'astrails/safe/backup'

require 'astrails/safe/source'
require 'astrails/safe/mysqldump'
require 'astrails/safe/archive'

require 'astrails/safe/pipe'
require 'astrails/safe/gpg'
require 'astrails/safe/gzip'

require 'astrails/safe/sink'
require 'astrails/safe/local'
require 'astrails/safe/s3'


module Astrails
  module Safe
    ROOT = File.join(File.dirname(__FILE__), "..", "..")

    def safe(&block)
      config = Config::Node.new(&block)
      #config.dump

      if databases = config[:mysqldump, :databases]
        databases.each do |name, config|
          Astrails::Safe::Mysqldump.new(name, config).backup.run(config, :gpg, :gzip, :local, :s3)
        end
      end

      if archives = config[:tar, :archives]
        archives.each do |name, config|
          Astrails::Safe::Archive.new(name, config).backup.run(config, :gpg, :gzip, :local, :s3)
        end
      end

      Astrails::Safe::TmpFile.cleanup
    end
  end
end
