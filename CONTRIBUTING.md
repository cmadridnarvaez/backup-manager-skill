# Contributing to Backup Manager

Thank you for your interest in contributing to Backup Manager! This document provides guidelines for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, OpenClaw version, shell)
- Any relevant logs or error messages

### Suggesting Features

Feature suggestions are welcome! Please open an issue with:
- A clear description of the feature
- The problem it solves
- Possible implementation approach
- Any alternatives considered

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style

- Use bash strict mode: `set -euo pipefail`
- Quote all variables: `"$VAR"` not `$VAR`
- Use meaningful variable names
- Add comments for complex logic
- Follow existing code patterns

### Testing

Before submitting:
- Test with `--dry-run` first
- Test each destination type (local, s3, remote)
- Verify backup files are created correctly
- Check retention cleanup works
- Test error handling

### Documentation

- Update README.md if adding features
- Update CHANGELOG.md with your changes
- Add examples for new features
- Update SKILL.md if behavior changes

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/backup-manager-skill.git
cd backup-manager-skill

# Make changes to scripts/backup.sh or other files

# Test locally
bash scripts/backup.sh --dry-run --verbose

# Commit and push
git add .
git commit -m "Description of changes"
git push origin main
```

## Code of Conduct

- Be respectful and constructive
- Focus on what's best for the community
- Accept constructive criticism gracefully
- Show empathy towards others

## Questions?

Feel free to open an issue for questions or join discussions.

Thank you for contributing!
