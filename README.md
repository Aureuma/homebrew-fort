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

## Release automation

This tap is updated automatically from the Fort release workflow (`Aureuma/fort`):

- builds and uploads multi-arch release archives
- updates `Formula/fort.rb` with new version + SHA256 checksums
- commits and pushes formula updates to this tap

You can also trigger formula updates manually using the workflow in this repo.
