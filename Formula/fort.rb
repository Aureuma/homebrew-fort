class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.5.0/fort_1.5.0_darwin_arm64.tar.gz"
      sha256 "1aa4e75df486d5843783de5c4f556414782ef2ba03bc464f9e483bc71111d525"
    else
      url "https://github.com/Aureuma/fort/releases/download/v1.5.0/fort_1.5.0_darwin_amd64.tar.gz"
      sha256 "02e3a55fed3f4e5ae38f6939b9970ba93e389ccbb1c2c7be2476ea880b5c2719"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/v1.5.0/fort_1.5.0_linux_arm64.tar.gz"
      sha256 "518783b4bc832a3d1669987b6b3d96516d1a9899479f977a5639ed2d3ab717f9"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/v1.5.0/fort_1.5.0_linux_amd64.tar.gz"
      sha256 "3c140653c428d38ff01395f839d018c40c76ff7de3e63ec4ad56cb3f68001d78"
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
