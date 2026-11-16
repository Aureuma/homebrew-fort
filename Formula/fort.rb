class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  version "1.4.0"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.4.0/fort_1.4.0_darwin_arm64.tar.gz"
      sha256 "11cf4acf1a696cc75c64cde543733d9e2c230a71be47f2556d8c43ed2d24adaa"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.4.0/fort_1.4.0_darwin_amd64.tar.gz"
      sha256 "197ab53f9217183051ef39164dd8dbe119ca82eab6a79ef560e19a88f2145f8c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.4.0/fort_1.4.0_linux_arm64.tar.gz"
      sha256 "0dde32525bd81e7190cb5fd905a91c3cdc7507bbd32a0b7e14123d3f677d5aff"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.4.0/fort_1.4.0_linux_amd64.tar.gz"
      sha256 "da304926f3fb12608d458c379ad53b4bbbb932ee3568b839008666988c0d1e1f"
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
