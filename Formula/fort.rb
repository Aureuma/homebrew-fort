class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.6.0/fort_1.6.0_darwin_arm64.tar.gz"
      sha256 "74d5b3e52f38ecf391aa5ed830885db87e001df2831c136bef58feb566118159"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.6.0/fort_1.6.0_darwin_amd64.tar.gz"
      sha256 "8f8b7ba9264b2f8f7e6f7224293c2aabee746b55d6f62cc1b0cffe093cd10288"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.6.0/fort_1.6.0_linux_arm64.tar.gz"
      sha256 "1040d7d77af7dcebd4aebc6710dec32bbecb3076ad35f9255836558e0444b009"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.6.0/fort_1.6.0_linux_amd64.tar.gz"
      sha256 "48206dfea5c83e7533d6443bfbcddfbab4cc2015124b92879716a6273e3ab7d4"
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
