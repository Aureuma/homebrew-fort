class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  version "1.2.0"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.2.0/fort_1.2.0_darwin_arm64.tar.gz"
      sha256 "6b98f5bf2d0523df50b9532bd75c234b1f151acce7c39cde491c2a8360e833af"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.2.0/fort_1.2.0_darwin_amd64.tar.gz"
      sha256 "3e08b915998131b733c9f2c1b6a6bab5eb421a6eb859f6330c26a1a92f001b8a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.2.0/fort_1.2.0_linux_arm64.tar.gz"
      sha256 "1137f73a8f1a5d3acbfadc4066f75b1f7bf0d98daf37bd68752f6e9945373cb0"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.2.0/fort_1.2.0_linux_amd64.tar.gz"
      sha256 "84c3a0b89958246f5739cd53b44a0b63a5ccf8d2314c217b177b5d550affa97b"
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
