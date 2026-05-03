# Security Policy

## Supported Versions

The following versions of Design Builder are currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of Design Builder seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Please do the following:

- **Do not** open a public issue describing the vulnerability
- **Do not** create a pull request with the fix
- **Do** email the maintainers directly at [INSERT SECURITY EMAIL]
- **Do** include as much information as possible:
  - Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
  - Full paths of source file(s) related to the manifestation of the issue
  - The location of the affected source code (tag/branch/commit or direct URL)
  - Any special configuration required to reproduce the issue
  - Step-by-step instructions to reproduce the issue
  - Proof-of-concept or exploit code (if possible)
  - Impact of the issue, including how an attacker might exploit it

### What to expect:

- We will acknowledge receipt of your vulnerability report within 3 business days
- We will provide an estimated time frame for a fix within 7 business days
- We will notify you when the vulnerability is fixed
- We will credit you in the release notes (unless you prefer to remain anonymous)
- We will work with you to coordinate disclosure timing

## Security Best Practices for Users

When using Design Builder in your applications:

- Keep the package updated to the latest version
- Follow secure coding practices in your Flutter/Dart code
- Be cautious when processing user input
- Validate all data before using it in UI components
- Review the code before using it in production environments

## Security Update Policy

Security updates will be released as patch versions (e.g., 1.0.1, 1.0.2) and will be clearly marked in the release notes.

We follow responsible disclosure practices and will:
- Fix vulnerabilities promptly
- Release updates quickly
- Document security fixes in CHANGELOG.md
- Credit security researchers who report valid issues

Thank you for helping keep Design Builder and its users safe!
