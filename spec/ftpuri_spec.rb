require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FTPUtils::FTPURI do
  it "should create a new URI if a valid FTP directory is provided" do
    uri = FTPUtils::FTPURI.parse("ftp://admin:test@myhost/path/to/directory")
    uri.dirname.should == "/path/to"
    uri.filename.should == "directory"
    uri.path.should == "/path/to/directory"
  end

  it "should create a new URI if just the hostname is provided" do
    uri = FTPUtils::FTPURI.parse("ftp://admin:test@myhost")
    uri.dirname.should == "/"
    uri.filename.should be_nil
    uri.path.should == "/"
  end

  it "should create a new URI if a valid FTP file is provided" do
    uri = FTPUtils::FTPURI.parse("ftp://admin:test@myhost/path/to/file.txt")
    uri.dirname.should == "/path/to"
    uri.filename.should == "file.txt"
    uri.path.should == "/path/to/file.txt"
  end
    
end
