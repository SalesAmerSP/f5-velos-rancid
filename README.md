# secured-generic

A ready-to-use GitHub repository template that sets up security best practices
for your project **before you write a single line of code** -- so you don't
have to figure it out after something goes wrong.

> **New to GitHub or security tooling?** Don't worry. This template does the
> heavy lifting. You click a button, follow a short checklist, and your repo
> is protected. No security expertise required.

## How to use this template

1. Click the green **Use this template** button at the top of this page, then
   choose **Create a new repository**.
2. Give your new repo a name and create it.
3. Clone it to your computer (or open it in your editor of choice).
4. **Follow the setup checklist** in
   [docs/SECURITY-SETUP.md](docs/SECURITY-SETUP.md). This is a short,
   step-by-step guide for the few settings that can't be copied automatically
   from a template.
5. **Search for `<TEMPLATE>` markers** and replace them with your project's
   real values (your GitHub username, repo name, etc.):

   ```bash
   grep -rn "<TEMPLATE>" .
   ```

6. Replace everything in this README below the horizontal rule with a
   description of your own project.
7. If Apache 2.0 isn't the right license for your project, swap out the
   [LICENSE](LICENSE) file. See the "License" section below for guidance.

That's it -- you're ready to start building.

---

## What's included

Here's what this template gives you out of the box:

| What | Where | What it does (in plain English) |
|---|---|---|
| **Vulnerability reporting** | [SECURITY.md](SECURITY.md) | Tells people how to privately report security issues instead of posting them publicly |
| **Dependency monitoring** | [.github/dependabot.yml](.github/dependabot.yml) | Automatically checks if any libraries your project depends on have known security problems, and opens a pull request to fix them |
| **Secret scanning** | [.github/workflows/gitleaks.yml](.github/workflows/gitleaks.yml) | Checks every push and pull request for accidentally committed passwords, API keys, or tokens |
| **Issue templates** | [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/) | Gives people a structured form for reporting bugs or requesting features |
| **PR template** | [.github/pull_request_template.md](.github/pull_request_template.md) | Reminds contributors to check for secrets, pin dependencies, and sign commits |
| **Contributor guide** | [CONTRIBUTING.md](CONTRIBUTING.md) | Explains how to contribute, including how to set up commit signing |
| **`.gitignore`** | [.gitignore](.gitignore) | Prevents common junk files (editor configs, build artifacts, OS files) from being committed |
| **License** | [LICENSE](LICENSE) | Apache 2.0 by default |

## What's NOT included (on purpose)

These things vary too much between projects to have useful defaults:

- **Tests / CI for your code.** Add your own test workflow once you know your language.
- **Code formatting / linting.** Add tools like `ruff`, `eslint`, `gofmt`, etc. for your language.
- **Docker / containers.** Add a Dockerfile when you need one.
- **Release automation.** Add a release workflow once you know how you want to ship.

## License

This template uses the **Apache 2.0** license. In short: anyone can use,
modify, and distribute your code, but they must give credit and can't
claim your project endorses their work.

**Why Apache 2.0 over MIT?** Apache 2.0 includes an explicit patent grant,
which protects both you and your users. MIT is simpler but leaves patent
rights unclear. Apache 2.0 is the standard for most major open-source
infrastructure projects (Kubernetes, Terraform, etc.).

If you need a different license:

| License | When to use it |
|---|---|
| **MIT** | You want maximum simplicity and don't care about patents |
| **BSD-3-Clause** | Like MIT, plus a clause preventing others from using your name to endorse their products |
| **MPL-2.0** | You want people to share back changes to *your* files, but they can keep their own code private |
| **GPL-3.0** | You want *all* derivative works to also be open source |
| **AGPL-3.0** | Like GPL, but also applies when someone runs a modified version as a web service |

## Updating this template

The template's security workflows use version tags (like `@v4`) that
automatically get minor updates. When you create a new repo from this
template, Dependabot will start tracking the exact versions for you.

Changes to this template do **not** automatically flow into repos already
created from it -- templates only seed new repos at creation time.
