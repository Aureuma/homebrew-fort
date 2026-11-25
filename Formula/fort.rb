class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  version "1.7.0"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.7.0/fort_1.7.0_darwin_arm64.tar.gz"
      sha256 "32dc3ccbd272e93d4c95b53d8941e38b8a2b6e489bbdaaecbb50cc361e3cbe3c"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.7.0/fort_1.7.0_darwin_amd64.tar.gz"
      sha256 "371efdc472ee05481a327d27528c216b6595e22e2e0245275113e6b1e4fec842"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.7.0/fort_1.7.0_linux_arm64.tar.gz"
      sha256 "cf22ca6132e8a3cd3aff6fa9fe7448290cad901b6af8487001a86529b9b375de"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.7.0/fort_1.7.0_linux_amd64.tar.gz"
      sha256 "ac96b168587affefde823f07ec1d2983e44c17bf03c1420c917dd45d580e4d75"
    end
  end

  def install
    stage = buildpath/"fort-stage"
    stage.mkpath
    system "tar", "-xzf", cached_download, "-C", stage

    ["fort", "fortd", "fort-agent"].each do |name|
      binary = Dir["#{stage}/fort_*/#{name}"].first
      binary = (stage/name).to_s if binary.nil? && (stage/name).exist?
      raise "#{name} binary not found in release archive" if binary.nil? || binary.empty?

      bin.install binary => name
      chmod 0o755, bin/name
    end
  end

  test do
    output = shell_output("#{bin}/fort version")
    assert_match version.to_s, output
    assert_predicate bin/"fortd", :executable?, "fortd was not installed"
    assert_predicate bin/"fort-agent", :executable?, "fort-agent was not installed"
  end
end
