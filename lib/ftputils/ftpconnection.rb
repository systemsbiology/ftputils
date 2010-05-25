class FTPUtils
  class FTPConnection
    cattr_accessor :connections

    def self.connect(uri)
      if uri.match(/^ftp:\/\/(.*?):(.*?)@(.*?)(\/.*)*\/(.*)$/)
        username = $1
        password = $2
        host = $3

        connection = self.establish_connection(host, username, password)

        # need to reset to the top directory since connections are cached and
        # could have been left elsewhere. this also provides a way to see if the 
        # connection has expired and needs to be reloaded
        begin
          connection.chdir "/"
        rescue Net::FTPTempError
          connection = self.establish_connection(host, username, password, true)
          retry
        end

        return connection
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
