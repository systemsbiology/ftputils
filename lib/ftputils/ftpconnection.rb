require 'timeout'

class FTPUtils
  class FTPConnection
    cattr_accessor :connections

    def self.connect(uri)
      timeout(FTPUtils.timeout_period) do
        if uri.match(/^ftp:\/\/(.*?):(.*?)@(.*?)(\/.*)*$/)
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
    rescue Timeout::Error
      raise "Connecting to #{uri} timed out after #{FTPUtils.timeout_period} seconds"
    end

    def self.clear_connection_cache
      self.connections = Hash.new
    end

    private

    def self.establish_connection(host, username, password, reload = false)
      self.connections ||= Hash.new

      connection_key = "#{username}@#{host}"
      return connections[connection_key] if connections[connection_key] && !reload

      connection = Net::FTPFXP.new
      connection.passive = true
      connection.connect(host)
      connection.login(username, password) if username && password

      connections[connection_key] = connection

      return connection
    end
  end
end
