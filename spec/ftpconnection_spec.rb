require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FTPUtils::FTPConnection do
  before(:each) do
    FTPUtils::FTPConnection.clear_connection_cache
  end

  describe "initializing a new FTP connection" do
    it "should raise an error if it doesn't look like an FTP connection" do
      lambda do
        FTPUtils::FTPConnection.connect("path/to/file.txt")
      end.should raise_error("Invalid FTP URL provided: path/to/file.txt")
    end

    it "should establish a connection to a directory" do
      mock_connection = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection)
      mock_connection.should_receive(:"passive=").with(true)
      mock_connection.should_receive(:connect).with("myhost")
      mock_connection.should_receive(:login).with("admin","test")
      mock_connection.should_receive(:chdir).with("/")

      FTPUtils::FTPConnection.connect("ftp://admin:test@myhost/path/to/directory")
    end

    it "should attempt to reconnect once if there is an error" do
      mock_connection = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection)
      mock_connection.should_receive(:"passive=").with(true)
      mock_connection.should_receive(:connect).with("myhost")
      mock_connection.should_receive(:login).with("admin","test")
      mock_connection.should_receive(:chdir).with("/").and_raise(Net::FTPTempError)
      mock_connection_2 = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection_2)
      mock_connection_2.should_receive(:"passive=").with(true)
      mock_connection_2.should_receive(:connect).with("myhost")
      mock_connection_2.should_receive(:login).with("admin","test")
      mock_connection_2.should_receive(:chdir).with("/").and_raise(Net::FTPPermError)

      lambda do
        FTPUtils::FTPConnection.connect("ftp://admin:test@myhost/path/to/file.txt")
      end.should raise_error(Net::FTPPermError)
    end
  end
end
