# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| Latest  | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please report it responsibly.

**Please do NOT open a public GitHub issue for security vulnerabilities.**

### How to Report

1. Email us at **support@clouddrove.com** with:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

2. You will receive an acknowledgment within **48 hours**

3. We will investigate and provide a timeline for a fix

### Response Timeline

| Severity | Acknowledgment | Fix Target |
|----------|---------------|------------|
| Critical | 24 hours      | 7 days     |
| High     | 48 hours      | 14 days    |
| Medium   | 72 hours      | 30 days    |
| Low      | 1 week        | Next release |

### Scope

This policy applies to:
- Terraform module code
- Example configurations
- CI/CD workflows
- Documentation containing sensitive patterns

### Out of Scope

- Vulnerabilities in Terraform itself (report to HashiCorp)
- Vulnerabilities in cloud provider APIs
- Issues in third-party dependencies (report upstream)

## Security Best Practices

When using our modules:
- Always pin module versions in production
- Review `tfsec` and `checkov` findings before deploying
- Use least-privilege IAM policies
- Enable encryption at rest and in transit where available
- Regularly update to the latest module version
