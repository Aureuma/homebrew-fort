#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Update Formula/fort.rb from release checksums.

Usage:
  scripts/update-formula.sh \
    --version <vX.Y.Z> \
    --checksums <path-or-url>
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

version=""
checksums_ref=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      version="${2:-}"
      shift 2
      ;;
    --checksums)
      checksums_ref="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[[ -n "${version}" ]] || die "--version is required"
[[ "${version}" == v* ]] || die "version must include v prefix"
[[ -n "${checksums_ref}" ]] || die "--checksums is required"

checksums_file=""
checksums_tmp="no"
cleanup() {
  if [[ "${checksums_tmp}" == "yes" && -n "${checksums_file}" && -f "${checksums_file}" ]]; then
    rm -f "${checksums_file}"
  fi
}
trap cleanup EXIT

if [[ "${checksums_ref}" =~ ^https?:// ]]; then
  checksums_file="$(mktemp)"
  checksums_tmp="yes"
  curl --proto '=https' --tlsv1.2 -fsSL "${checksums_ref}" -o "${checksums_file}"
else
  checksums_file="${checksums_ref}"
fi

[[ -f "${checksums_file}" ]] || die "checksums file not found: ${checksums_file}"

lookup_sha() {
  local file_name="$1"
  local sha
  sha="$(awk -v f="${file_name}" '$2 == f { print $1 }' "${checksums_file}" | tail -n1)"
  [[ -n "${sha}" ]] || die "checksum not found for ${file_name}"
  echo "${sha}"
}

version_nov="${version#v}"
asset_darwin_arm64="fort_${version_nov}_darwin_arm64.tar.gz"
asset_darwin_amd64="fort_${version_nov}_darwin_amd64.tar.gz"
asset_linux_arm64="fort_${version_nov}_linux_arm64.tar.gz"
asset_linux_amd64="fort_${version_nov}_linux_amd64.tar.gz"

sha_darwin_arm64="$(lookup_sha "${asset_darwin_arm64}")"
sha_darwin_amd64="$(lookup_sha "${asset_darwin_amd64}")"
sha_linux_arm64="$(lookup_sha "${asset_linux_arm64}")"
sha_linux_amd64="$(lookup_sha "${asset_linux_amd64}")"

mkdir -p Formula
cat > Formula/fort.rb <<RUBY
class Fort < Formula
  desc "Policy and authentication API for Vault secret operations"
  homepage "https://github.com/Aureuma/fort"
  version "${version_nov}"
  license "AGPL-3.0-only"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/${version}/${asset_darwin_arm64}"
      sha256 "${sha_darwin_arm64}"
    else
      url "https://github.com/Aureuma/fort/releases/download/${version}/${asset_darwin_amd64}"
      sha256 "${sha_darwin_amd64}"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Aureuma/fort/releases/download/${version}/${asset_linux_arm64}"
      sha256 "${sha_linux_arm64}"
    elsif Hardware::CPU.intel?
      url "https://github.com/Aureuma/fort/releases/download/${version}/${asset_linux_amd64}"
      sha256 "${sha_linux_amd64}"
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
RUBY

echo "updated Formula/fort.rb for ${version}"
