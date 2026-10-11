class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  version "1.0.8"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.0.8/fort_1.0.8_darwin_arm64.tar.gz"
      sha256 "38a534a794729b07e9c4a5b2b213a5ce17cb54ad731eb97f8cb670899105e168"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.0.8/fort_1.0.8_darwin_amd64.tar.gz"
      sha256 "6011a1160c65e134a55a6f95309ab0b29da350839513aa5d5e36e2d1ca825c4d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.0.8/fort_1.0.8_linux_arm64.tar.gz"
      sha256 "3ea9584e61e6e8598ea93c967f4d0b2ff3b61be74caf27e6ad994e744ad44693"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.0.8/fort_1.0.8_linux_amd64.tar.gz"
      sha256 "4e24be2217942d23eec4b1549753e950f3ccb275b50791907200c27d252f272b"
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
