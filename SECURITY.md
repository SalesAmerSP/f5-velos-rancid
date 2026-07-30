# Security Policy

## How to report a security vulnerability

> **Important:** Please do **not** open a regular GitHub issue for security
> problems. Security issues need to be handled privately so that a fix can
> be prepared before the details are made public.

Instead, use GitHub's built-in private reporting:

1. Go to the **Security** tab of this repository.
2. Click **Report a vulnerability**.
3. Fill out the form and submit.

Or use this direct link:
<https://github.com/SalesAmerSP/f5-velos-rancid/security/advisories/new>

### What to include in your report

The more detail you can provide, the faster we can understand and fix the
issue. Try to include:

- **What the problem is** and what someone could do with it (e.g., "an
  attacker could read files they shouldn't be able to access")
- **How to reproduce it** -- step-by-step instructions or a small example
- **Which file(s) or component(s)** are affected, if you know
- **What version or commit** you were using when you found it
- **Any workaround** you're aware of

Don't worry if you can't fill in every detail -- partial reports are still
very helpful.

### What happens after you report

This project is maintained by volunteers, so response times are
best-effort:

- We'll acknowledge your report within a few business days
- We'll assess the severity and work on a fix
- Once a fix is ready, we'll coordinate with you on disclosure

## Supported versions

Only the latest version of the `main` branch is actively supported.
Fixes go into `main` and are not backported to older releases. To stay
protected, use a current clone of `main`.

## How this project protects its supply chain

This project uses several layers of automated security tooling. You don't
need to understand all of these to contribute, but here's what's running
behind the scenes:

- **Pinned dependencies** -- All libraries this project depends on are
  locked to specific versions, so a compromised update can't sneak in
  unnoticed.

- **Dependabot** -- Automatically watches for known vulnerabilities in
  our dependencies and opens pull requests to update them.
  See [.github/dependabot.yml](.github/dependabot.yml).

- **Gitleaks (secret scanning)** -- Every push and pull request is
  scanned for accidentally committed passwords, API keys, or tokens.
  See [.github/workflows/gitleaks.yml](.github/workflows/gitleaks.yml).

- **Branch protection** -- The `main` branch is protected against
  force-pushes and direct commits. All changes go through pull requests.

- **Commit signing** -- Contributors are encouraged to sign their
  commits to prove authorship. See
  [CONTRIBUTING.md](CONTRIBUTING.md#commit-signing).
