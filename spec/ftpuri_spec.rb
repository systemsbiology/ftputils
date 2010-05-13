require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FTPURI" do
  before(:each) do
    FTPUtils::FTPURI.clear_connection_cache
  end

  describe "initializing a new FTP URI" do
    it "should raise an error if it doesn't look like an FTP URI" do
      lambda do
        FTPUtils::FTPURI.new("path/to/file.txt")
      end.should raise_error("Invalid FTP URL provided: path/to/file.txt")
    end

    it "should establish a connection to a directory" do
      mock_connection = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection)
      mock_connection.should_receive(:"passive=").with(true)
      mock_connection.should_receive(:connect).with("myhost")
      mock_connection.should_receive(:login).with("admin","test")
      mock_connection.should_receive(:chdir).with("/path/to/directory")
      mock_connection.should_receive(:chdir).with("/")

      uri = FTPUtils::FTPURI.new("ftp://admin:test@myhost/path/to/directory")
      uri.folder.should == "/path/to/directory"
      uri.filename.should == nil
      uri.path.should == "/path/to/directory"
      uri.directory.should be_true
      uri.connection.should == mock_connection
    end

    it "should establish a connection to a file" do
      mock_connection = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection)
      mock_connection.stub!(:asdf).and_return("zxcv")
      mock_connection.should_receive(:"passive=").with(true)
      mock_connection.should_receive(:connect).with("myhost")
      mock_connection.should_receive(:login).with("admin","test")
      mock_connection.should_receive(:chdir).with("/path/to/file.txt").and_raise(Net::FTPPermError)
      mock_connection.should_receive(:chdir).with("/")

      uri = FTPUtils::FTPURI.new("ftp://admin:test@myhost/path/to/file.txt")
      uri.folder.should == "/path/to"
      uri.filename.should == "file.txt"
      uri.path.should == "/path/to/file.txt"
      uri.directory.should be_false
      uri.connection.should == mock_connection
    end

    it "should attempt to reconnect once if there is an error" do
      mock_connection = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection)
      mock_connection.should_receive(:"passive=").with(true)
      mock_connection.should_receive(:connect).with("myhost")
      mock_connection.should_receive(:login).with("admin","test")
      mock_connection.should_receive(:chdir).with("/path/to/file.txt").and_raise(Net::FTPTempError)
      mock_connection_2 = mock(Net::FTPFXP)
      Net::FTPFXP.should_receive(:new).and_return(mock_connection_2)
      mock_connection_2.should_receive(:"passive=").with(true)
      mock_connection_2.should_receive(:connect).with("myhost")
      mock_connection_2.should_receive(:login).with("admin","test")
      mock_connection_2.should_receive(:chdir).with("/path/to/file.txt").and_raise(Net::FTPPermError)
      mock_connection_2.should_receive(:chdir).with("/")

      uri = FTPUtils::FTPURI.new("ftp://admin:test@myhost/path/to/file.txt")
      uri.folder.should == "/path/to"
      uri.filename.should == "file.txt"
      uri.path.should == "/path/to/file.txt"
      uri.directory.should be_false
      uri.connection.should == mock_connection_2
    end
  end
end
