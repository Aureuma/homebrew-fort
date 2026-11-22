# Fort Homebrew Tap

Homebrew tap for the `fort` CLI release binaries.

## Installation

```bash
brew install aureuma/fort/fort
```

Homebrew third-party install syntax is `user/repo/formula`, so `brew install aureuma/fort` is not a valid formula reference.

Or install formula directly (no auto-updates from tap):

```bash
brew install https://raw.githubusercontent.com/Aureuma/homebrew-fort/main/Formula/fort.rb
```

Optional explicit tap flow:

```bash
brew tap aureuma/fort
brew install fort
```

## Usage

```bash
fort --help
fort version
fort doctor
```

## Supported platforms

- macOS: Apple Silicon (`arm64`), Intel (`amd64`)
- Linux: `arm64`, `amd64`

## Release automation (local-only)

This tap has no GitHub Actions workflows. All checks and formula updates run
locally. Before pushing, run the gates:

```bash
scripts/check.sh
```

This runs: formula syntax check, formula sanity checks, checksum verification
of every release asset against the upstream `checksums.txt`, and a clean
`brew audit` (in an isolated temporary tap; your own taps are untouched).

To update the formula for a new Fort release, run:

```bash
scripts/update-formula.sh \
  --version vX.Y.Z \
  --checksums https://github.com/Aureuma/fort/releases/download/vX.Y.Z/checksums.txt
scripts/check.sh
```

Then commit `Formula/fort.rb` (and `VERSION` when it changes) and push.
