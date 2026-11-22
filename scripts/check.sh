#!/usr/bin/env bash
# Local gates for the homebrew-fort tap (replaces .github/workflows/ci.yml).
#
# Usage:
#   scripts/check.sh
#
# Gates:
#   1. formula syntax (Ruby compile check via Homebrew's vendored Ruby)
#   2. formula sanity (required stanza + install contract, update script usable)
#   3. checksum verify (formula sha256 values match the upstream checksums.txt)
#   4. brew audit (clean, via an isolated temporary tap)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA="${REPO_ROOT}/Formula/fort.rb"

pass() { echo "ok: $*"; }
die() { echo "error: $*" >&2; exit 1; }

[[ -f "${FORMULA}" ]] || die "formula not found: ${FORMULA}"

# --- 1. formula syntax ---
brew ruby -e 'RubyVM::InstructionSequence.compile_file("Formula/fort.rb")' >/dev/null 2>&1 \
  || die "formula has Ruby syntax errors"
pass "formula syntax"

# --- 2. formula sanity ---
grep -q '^class Fort < Formula' "${FORMULA}" || die "formula class declaration missing"
grep -q 'test do' "${FORMULA}" || die "formula test block missing"
grep -q '"fort", "fortd", "fort-agent"' "${FORMULA}" || die "formula must install fort, fortd, fort-agent"
test -x "${REPO_ROOT}/scripts/update-formula.sh" || die "scripts/update-formula.sh is not executable"
"${REPO_ROOT}/scripts/update-formula.sh" --help >/dev/null || die "scripts/update-formula.sh --help failed"
pass "formula sanity"

# --- 3. checksum verify ---
tag="$(grep -o 'releases/download/v[0-9][0-9.]*/' "${FORMULA}" | head -n1 | cut -d/ -f3)"
[[ -n "${tag}" ]] || die "could not determine release tag from formula URLs"
checksums_url="https://github.com/Aureuma/fort/releases/download/${tag}/checksums.txt"
checksums_file="$(mktemp)"
curl --proto '=https' --tlsv1.2 -fsSL "${checksums_url}" -o "${checksums_file}" \
  || die "could not download ${checksums_url}"

version_nov="${tag#v}"
verified=0
for platform in darwin_arm64 darwin_amd64 linux_arm64 linux_amd64; do
  asset="fort_${version_nov}_${platform}.tar.gz"
  expected="$(awk -v f="${asset}" '$2 == f { print $1 }' "${checksums_file}" | tail -n1)"
  [[ -n "${expected}" ]] || die "checksum not found for ${asset} in ${checksums_url}"
  actual="$(grep -A1 "${asset}" "${FORMULA}" | grep -o '[0-9a-f]\{64\}')"
  [[ -n "${actual}" ]] || die "sha256 for ${asset} missing from formula"
  [[ "${expected}" == "${actual}" ]] || die "sha256 mismatch for ${asset}"
  verified=$((verified + 1))
done
pass "checksum verify (${verified}/4 assets, ${tag})"

# --- 4. brew audit (isolated temp tap, leaves user taps untouched) ---
tap="fortcheck/local"
tap_repo="$(brew --repo "${tap}" 2>/dev/null || true)"
if [[ -z "${tap_repo}" ]]; then
  brew tap-new "${tap}" >/dev/null \
    || die "could not create temporary tap ${tap}"
  tap_repo="$(brew --repo "${tap}")"
  created_tap="yes"
else
  created_tap="no"
fi
cleanup() {
  rm -f "${checksums_file}"
  if [[ "${created_tap:-no}" == "yes" ]]; then
    brew untap "${tap}" >/dev/null 2>&1 || true
  else
    rm -f "${tap_repo}/Formula/fort.rb"
  fi
}
trap cleanup EXIT
mkdir -p "${tap_repo}/Formula"
cp "${FORMULA}" "${tap_repo}/Formula/fort.rb"
brew trust "${tap}" >/dev/null 2>&1 || true
brew audit "${tap}/fort" || die "brew audit reported problems"
pass "brew audit"

echo "all gates passed"
