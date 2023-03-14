# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security
- Switch to go modules (remove vendored dependencies), upgrade to aws-sdk-go-v2.  
  [cyberark/summon-s3#23](https://github.com/cyberark/summon-s3/pull/23)

## [0.2.0] - 2017-11-22
### Added
- Added alpine linux binary distribution

### Changed
- Updated aws-sdk dependency to support IAM session credentials
- Update session logic to support
- Build binaries with Go 1.9 Docker containers

## [0.1.0] - 2015-06-07
### Added
- Initial release

[Unreleased]: https://github.com/cyberark/summon-s3/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/cyberark/summon-s3/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/cyberark/summon-s3/releases/tag/v0.1.0
