class FTPUtils
  class FTPURI
    cattr_accessor :connections

    attr_accessor :connection, :path, :folder, :filename, :directory

    def initialize(uri)
      if uri.match(/^ftp:\/\/(.*?):(.*?)@(.*?)(\/.*)*\/(.*)$/)
        username = $1
        password = $2
        host = $3
        self.folder = $4 || "/"
        self.filename = $5
        self.path = folder + "/" + filename

        self.connection = FTPUtils::FTPURI.establish_connection(host, username, password)

        # see whether the URL is for a file or directory
        self.directory = false
        begin
          connection.chdir(path)
          self.folder = path 
          self.filename = nil
          self.directory = true
        rescue Net::FTPPermError
          # do nothing
        rescue Net::FTPTempError
          # reload connection if there is a problem with it
          self.connection = FTPURI.establish_connection(host, username, password, true)
          retry
        end

        connection.chdir "/"
      else
        raise "Invalid FTP URL provided: #{uri}"
      end
    end

    def self.clear_connection_cache
      self.connections = Hash.new
    end

    private

    def self.establish_connection(host, username, password, reload = false)
      self.connections ||= Hash.new

      return connections[host] if connections[host] && !reload

      connection = Net::FTPFXP.new
      connection.passive = true
      connection.connect(host)
      connection.login(username, password) if username && password

      connections[host] = connection

      return connection
    end
  end
end
