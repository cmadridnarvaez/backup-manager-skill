# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-14

### Added
- Initial release of Backup Manager skill
- Multi-destination backup support: local, S3, remote (rsync/SSH)
- Automatic retention management (configurable)
- Dry-run mode for testing
- Verbose output option
- Support for AWS S3 and S3-compatible services (MinIO, Wasabi, etc.)
- SSH key-based authentication for remote backups
- Comprehensive documentation (SKILL.md, README.md)
- Installation script with auto-configuration
- MIT license

### Features
- Backup of cognitive files: SOUL.md, MEMORY.md, TOOLS.md, AGENTS.md, USER.md, IDENTITY.md
- Backup of memory/ directory with daily logs
- Configurable via simple bash config file
- Colorized output for better UX
- Error handling and exit codes
- Compatible with SecureClaw security auditing

## [Unreleased]

### Planned
- Encryption support for backups (GPG)
- Webhook notifications (Discord, Slack)
- Compression option (gzip)
- Restore functionality
- Backup verification (checksums)
- Docker container support
- Windows/WSL support improvements
