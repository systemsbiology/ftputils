begin
  require 'ftpfxp'
rescue LoadError
  require 'rubygems'
  require 'ftpfxp'
end

require 'fileutils'
require 'open-uri'
require 'timeout'

class FTPUtils

  @@timeout_period = 300

  def self.timeout_period
    # default to a 5 minute timeout
    @@timeout_period || 300
  end

  def self.timeout_period=(seconds)
    @@timeout_period = seconds
  end

  def self.cp(src, dest, options = {})
    timeout(timeout_period) do
      # handle all combinations of copying to/from FTP and local files
      case [ftp_url?(src), ftp_url?(dest)]
      when [true, true]
        raise "src should be a filename, not a directory" if FTPFile.directory?(src)

        dest_path = FTPFile.dirname(dest) + "/" + ( FTPFile.basename(dest) || FTPFile.basename(src) )
        FTPConnection.connect(src).fxpto(FTPConnection.connect(dest), dest_path, FTPFile.relative_path(src))
      when [true, false]
        raise "src should be a filename, not a directory" if FTPFile.directory?(src)

        filename = FTPFile.basename(src)

        if File.directory? dest
          dest += "/#{filename}"
        end

        connection = FTPConnection.connect(src)
        connection.chdir FTPFile.dirname(src)
        connection.getbinaryfile filename, dest, 1024
      when [false, true]
        raise "src should be a filename, not a directory" if File.directory? src

        dest_path = FTPFile.relative_path(dest)

        if FTPFile.directory?(dest)
          dest_path += "/#{File.basename(src)}"
        end

        connection = FTPConnection.connect(dest)
        connection.chdir FTPFile.dirname(dest)

        connection.putbinaryfile src, dest_path, 1024
      when [false, false]
        FileUtils.cp src, dest, options
      end
    end
  rescue Net::FTPPermError
    raise "Unable to copy #{src} to #{dest}, possibly due to FTP server permissions"
  rescue Timeout::Error
    raise "Copying #{src} to #{dest} timed out after #{timeout_period} seconds"
  end

  def self.rm(path)
    timeout(timeout_period) do
      if ftp_url?(path)
        raise "Can't use FTPUtils.rm on directories. Instead use FTPUtils.rm_r" if FTPFile.directory?(path)

        connection = FTPConnection.connect(path)
        connection.chdir FTPFile.dirname(path)
        connection.delete FTPFile.basename(path)
      else
        FileUtils.rm path
      end
    end
  rescue Timeout::Error
    raise "Removing #{path} timed out after #{timeout_period} seconds"
  end

  def self.mv(src, dest, options = {})
    cp(src, dest, options)
    rm(src)
  end

  def self.rm_r(path)
    timeout(timeout_period) do
      if ftp_url?(path)
        if FTPFile.directory?(path) 
          connection = FTPConnection.connect(path)
          connection.chdir FTPFile.relative_path(path)

          files = connection.nlst
          files.each {|file| rm_r "#{path}/#{file}"}

          connection.rmdir FTPFile.relative_path(path)
        else
          rm(path)
        end
      else
        FileUtils.rm_r path
      end
    end
  rescue Timeout::Error
    raise "Removing #{path} timed out after #{timeout_period} seconds"
  end

  def self.mkdir_p(path)
    timeout(timeout_period) do
      if ftp_url?(path)
        connection = FTPConnection.connect(path)

        subdirs = FTPFile.relative_path(path).split(/\//)
        subdirs.each do |subdir|
          next if subdir == ""

          connection.mkdir subdir
          connection.chdir subdir
        end
      else
        FileUtils.mkdir_p path
      end
    end
  rescue Timeout::Error
    raise "Creating #{path} timed out after #{timeout_period} seconds"
  end

  def self.cp_r(src, dest, options = {})
    timeout(timeout_period) do
      # handle all combinations of copying to/from FTP and local files
      if ftp_url?(src)
        if FTPFile.directory?(src) 
          mkdir_p dest

          connection = FTPConnection.connect(src)
          files = connection.nlst
          files.each {|file| cp_r "#{src}/#{file}", "#{dest}/#{file}", options}
        else
          cp(src, dest, options)
        end
      elsif ftp_url?(dest)
        if FTPFile.directory?(dest) 
          mkdir_p dest

          files = Dir.entries(src)
          files.each {|file| cp_r "#{src}/#{file}", "#{dest}/#{file}", options}
        else
          cp(src, dest, options)
        end
      else
        FileUtils.cp_r src, dest
      end
    end
  rescue Timeout::Error
    raise "Copying #{src} to #{dest} timed out after #{timeout_period} seconds"
  end

  def self.ls(path)
    timeout(timeout_period) do
      if ftp_url?(path)
        if FTPFile.directory?(path) 
          connection = FTPConnection.connect(path)
          connection.chdir FTPFile.relative_path(path)

          return connection.nlst
        else
          nil
        end
      else
        Dir.entries path
      end
    end
  rescue Timeout::Error
    raise "Listing #{path} timed out after #{timeout_period} seconds"
  end

  private

  def self.ftp_url?(str)
    str.match(/^ftp:\/\//i) ? true : false
  end

end

require 'ftputils/ext/class'
require 'ftputils/ftpconnection'
require 'ftputils/ftpuri'
require 'ftputils/ftpfile'
