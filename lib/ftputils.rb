begin
  require 'ftpfxp'
rescue LoadError
  require 'rubygems'
  require 'ftpfxp'
end

require 'fileutils'
require 'ftputils/ext/class'
require 'ftputils/ftpuri'

class FTPUtils
  def self.cp(src, dest, options = {})
    # handle all combinations of copying to/from FTP and local files
    case [ftp_url?(src), ftp_url?(dest)]
    when [true, true]
      src_uri = FTPURI.new(src)
      dest_uri = FTPURI.new(dest)

      raise "src should be a filename, not a directory" if src_uri.directory

      dest_path = dest_uri.folder + "/" + (dest_uri.filename || src_uri.filename)
      src_uri.connection.fxpto(dest_uri.connection, dest_path, src_uri.path)
    when [true, false]
      src_uri = FTPURI.new(src)
      raise "src should be a filename, not a directory" if src_uri.directory

      if File.directory? dest
        dest += "/#{src_uri.filename}"
      end

      src_uri.connection.chdir src_uri.folder
      src_uri.connection.getbinaryfile src_uri.filename, dest, 1024
    when [false, true]
      raise "src should be a filename, not a directory" if File.directory? src

      dest_uri = FTPURI.new(dest)

      if dest_uri.directory
        dest_uri.path += "/#{File.basename(src)}"
      end

      dest_uri.connection.chdir dest_uri.folder
      dest_uri.connection.putbinaryfile src, dest_uri.path, 1024
    when [false, false]
      FileUtils.cp src, dest, options
    end
  end

  def self.rm(path)
    if ftp_url?(path)
      ftp = FTPURI.new(path)
      
      raise "Can't use FTPUtils.rm on directories. Instead use FTPUtils.rm_r" if ftp.directory

      ftp.connection.chdir ftp.folder
      ftp.connection.delete ftp.filename
    else
      FileUtils.rm path
    end
  end

  def self.mv(src, dest, options = {})
    cp(src, dest, options)
    rm(src)
  end

  def self.rm_r(path)
    if ftp_url?(path)
      ftp = FTPURI.new(path)
      if ftp.directory 
        files = ftp.connection.nlst
        
        files.each {|file| rm_r "#{path}/#{file}"}

        ftp.connection.rmdir ftp.path
      else
        rm(path)
      end
    else
      FileUtils.rm_r path
    end
  end

  def self.mkdir_p(path)
    if ftp_url?(path)
      ftp = FTPURI.new(path)
      
      subdirs = ftp.path.split(/\//)
      subdirs.each do |subdir|
        next if subdir == ""

        ftp.connection.mkdir subdir
        ftp.connection.chdir subdir
      end
    else
      FileUtils.mkdir_p path
    end
  end

  def self.cp_r(src, dest, options = {})
  
  end

  private

  def self.ftp_url?(str)
    str.match(/^ftp:\/\//i) ? true : false
  end

#  def self.is_dir?(path)
#    if ftp_url?(path)
#      ftp = FTPURI.new(path)
#      
#      begin
#        ftp.connection.chdir ftp.path
#
#        return true
#      rescue
#        return false
#      end
#    else
#      File.directory? path
#    end
#  end

end
