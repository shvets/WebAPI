class Grabbook < Formula
  desc "Grabs book from audioknigi.club by url"
  homepage "https://github.com/shvets/WebAPI"
  url "https://github.com/shvets/WebAPI/archive/0.1.0.tar.gz"
  sha256 ""
  head "https://github.com/shvets/WebAPI.git"

  depends_on :xcode

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end
end
