class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  version "1.1.0"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.1.0/fort_1.1.0_darwin_arm64.tar.gz"
      sha256 "265a5340b948dea7ee359a2df45231073e1b78fafc5f3114bb22d7c3735f6f25"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.1.0/fort_1.1.0_darwin_amd64.tar.gz"
      sha256 "ee9497844c4bfa34c28c81afbd24d8a28b6c5311dc72a2204f504529077a3442"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.1.0/fort_1.1.0_linux_arm64.tar.gz"
      sha256 "ee1ba18911fe23e5237a0eae62d8eb52bdc2bed85e952b1a29b1dd599d1960bd"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.1.0/fort_1.1.0_linux_amd64.tar.gz"
      sha256 "61a778643cc9749e1b117af0c8634a68dbb379ee75600586abaea1d8d69055a4"
    end
  end

  def install
    stage = buildpath/"fort-stage"
    stage.mkpath
    system "tar", "-xzf", cached_download, "-C", stage

    binary = Dir["#{stage}/fort_*/fort"].first
    binary = (stage/"fort").to_s if binary.nil? && (stage/"fort").exist?
    raise "fort binary not found in release archive" if binary.nil? || binary.empty?

    bin.install binary => "fort"
    chmod 0o755, bin/"fort"
  end

  test do
    output = shell_output("#{bin}/fort version")
    assert_match version.to_s, output
  end
end
