# Contributing

We welcome contributions! This document provides guidelines for contributing to this project.

## Code of Conduct

Please be respectful and constructive. We are committed to providing a welcoming and inclusive experience for everyone.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch from `master`
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.10.0
- [pre-commit](https://pre-commit.com/#install)
- [TFLint](https://github.com/terraform-linters/tflint)
- [terraform-docs](https://terraform-docs.io/)

### Local Development

```bash
# Install pre-commit hooks
pre-commit install

# Run all pre-commit checks
pre-commit run -a

# Format code
terraform fmt -recursive

# Validate module
terraform init -backend=false
terraform validate
```

## Pull Request Process

### Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/). All commit messages and PR titles must follow this format:

```
type: description
```

**Allowed types:** `fix`, `feat`, `docs`, `ci`, `chore`, `test`, `refactor`, `style`, `perf`, `build`, `revert`

**Examples:**
- `feat: add support for custom tags`
- `fix: correct subnet CIDR calculation`
- `docs: update usage examples`
- `ci: pin workflow actions to SHA`

### PR Checklist

- [ ] Code follows the existing style and conventions
- [ ] Updated or added examples in `examples/` directory
- [ ] Ran `pre-commit run -a` locally
- [ ] Updated documentation if needed
- [ ] All CI checks pass

### What to Include

- Clear description of what changed and why
- Link to any related issues
- Example usage if adding new features
- Test evidence (terraform validate output, plan output)

## Module Structure

```
module/
├── main.tf           # Primary resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider and Terraform version constraints
├── locals.tf         # Local values (if needed)
├── data.tf           # Data sources (if needed)
├── examples/         # Usage examples
│   ├── basic/        # Minimal working example
│   └── complete/     # Full-featured example
├── README.md         # Documentation (auto-generated)
├── README.yaml       # Documentation source
└── CHANGELOG.md      # Version history
```

## Versioning

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

## Questions?

Open an issue or reach out at **support@clouddrove.com**.
