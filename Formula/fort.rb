class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.6.1/fort_1.6.1_darwin_arm64.tar.gz"
      sha256 "250565dac17a12281a17bdf22d2ce7167f0f469b4308da3b9ea0ed5eb8d15306"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.6.1/fort_1.6.1_darwin_amd64.tar.gz"
      sha256 "9ad7e36c2a018baa33c56f7ae44c85870dd9f7396cd9857f55c3d660a1951ac5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.6.1/fort_1.6.1_linux_arm64.tar.gz"
      sha256 "b5721eda05bd4597bff872b8104316514e8d5f36f0390ada95813cfce6a23f83"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.6.1/fort_1.6.1_linux_amd64.tar.gz"
      sha256 "87771face89f545aef80ab65a804d4ff2ecfd3ab65403e23e3bc6b4ed73ae1b8"
    end
  end

  def install
    stage = buildpath/"fort-stage"
    stage.mkpath
    system "tar", "-xzf", cached_download, "-C", stage

    ["fort", "fortd", "fort-agent"].each do |name|
      binary = Dir["#{stage}/fort_*/#{name}"].first
      binary = (stage/name).to_s if binary.nil? && (stage/name).exist?
      raise "#{name} binary not found in release archive" if binary.blank?

      bin.install binary => name
      chmod 0755, bin/name
    end
  end

  test do
    output = shell_output("#{bin}/fort version")
    assert_match version.to_s, output
    assert_predicate bin/"fortd", :executable?, "fortd was not installed"
    assert_predicate bin/"fort-agent", :executable?, "fort-agent was not installed"
  end
end
