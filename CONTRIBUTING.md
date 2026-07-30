# Contributing

Thanks for your interest in contributing! This guide will help you get
started, whether this is your first time using GitHub or your hundredth.

## Reporting bugs and requesting features

Use the **Issues** tab at the top of the repository:

- **Bug?** Click "New issue" and choose the **Bug Report** template.
  Describe what happened, what you expected, and how to reproduce it.
- **Feature idea?** Choose the **Feature Request** template. Explain
  the problem you're trying to solve (not just the solution you have
  in mind).

> **Found a security vulnerability?** Do **not** open a public issue.
> Instead, follow the private reporting steps in
> [SECURITY.md](SECURITY.md).

## How to submit a change (pull request)

If you're new to pull requests, here's the process step by step:

1. **Fork the repository** -- Click the "Fork" button at the top right of
   the repo page. This creates your own copy to work on.
2. **Create a branch** -- Make a new branch for your change (e.g.,
   `fix-typo-in-readme`). Don't work directly on `main`.
3. **Make your changes** -- Edit files, add features, fix bugs.
4. **Test your changes** -- Run any tests, formatters, or linters the
   project uses before pushing.
5. **Open a pull request** -- Go back to the original repo and click
   "New pull request". Fill out the template completely -- the checklist
   is there to catch common mistakes before a reviewer has to.
6. **Respond to feedback** -- A reviewer may ask questions or request
   changes. Add new commits to your branch to address them (don't
   force-push during review unless asked -- it makes it harder for
   reviewers to see what changed).

If you already have write access to the repo, you can skip the fork and
just create a branch directly.

## Writing good commits

- **One change per commit.** A commit that fixes a bug shouldn't also
  reformat unrelated code or bump dependencies.
- **Write for the future reader.** The first line says *what* changed.
  The body explains *why* and what alternatives you considered.
- **Never include sensitive information** in commits, PR descriptions,
  issues, or comments. This means:
  - No passwords, API keys, or tokens
  - No real customer data
  - No real public IP addresses or internal hostnames
  - Use placeholder values instead: `192.0.2.X`, `example.com`,
    `<redacted>`
  - When in doubt, treat it as sensitive

## Commit signing

We **strongly recommend** signing your commits. Signed commits show a
green "Verified" badge on GitHub, proving the commit really came from
you and wasn't tampered with.

### Why it matters

Without signing, anyone who gets access to a GitHub account (through a
stolen token, for example) could push commits pretending to be you.
Signing adds a cryptographic proof of identity.

### How to set it up (one-time, takes about 5 minutes)

The easiest method uses the SSH key you likely already have for pushing
to GitHub. No extra software needed.

**Step 1: Check if you have an SSH key**

```bash
ls ~/.ssh/id_ed25519.pub
```

If you see the file, you're good. If not, create one:

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Press Enter to accept the defaults when prompted.

**Step 2: Tell Git to use it for signing**

Run these four commands (copy-paste them one at a time):

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

**Step 3: Add the key to GitHub as a signing key**

1. Go to [github.com/settings/keys](https://github.com/settings/keys)
2. Click **New SSH key**
3. Set the title to something like "My laptop - signing"
4. Change **Key type** to **Signing Key** (not Authentication Key)
5. Paste the contents of your `~/.ssh/id_ed25519.pub` file
6. Click **Add SSH key**

> **Note:** Even if you already added this key for authentication (pushing
> code), you need to add it **again** as a signing key. They are separate
> entries.

**Step 4: Test it**

```bash
git commit --allow-empty -m "test signing"
git log -1 --show-signature
```

You should see `Good "git" signature with ED25519 key SHA256:...`. Push
the commit and check it on GitHub -- it should show a green **Verified**
badge.

To clean up the test commit:

```bash
git reset --hard HEAD~1
```

### Alternative: GPG signing

If your organization uses GPG, follow
[GitHub's GPG signing guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
instead. The result is the same Verified badge.

### Why we recommend but don't require signing

Requiring signed commits means every contributor must set up signing
before their first PR, which can be a barrier for new contributors. For
most projects, recommending it and gently reminding people in PR reviews
is the right balance. Larger projects may want to enforce it through
branch protection settings.

## Dependencies

When adding a dependency (a library or package your code uses):

- **Pin it to a specific version** so that a future update can't
  silently break things. Every language has its own way of doing this:

  | Language | How to pin | How to install safely |
  |---|---|---|
  | Python | `pip-compile --generate-hashes requirements.in` | `pip install --require-hashes -r requirements.txt` |
  | Node.js | `npm install` (creates `package-lock.json`) | `npm ci` |
  | Go | `go mod tidy` (creates `go.sum`) | `go mod verify` |
  | Rust | `cargo build` (creates `Cargo.lock`) | `cargo build --locked` |
  | Ruby | `bundle install` (creates `Gemfile.lock`) | `bundle install --frozen` |

- **Think twice before adding dependencies.** Every library you add is
  code written by someone else that you haven't reviewed. If you can do
  it in a few lines with the standard library, prefer that.
- **When updating a dependency, say why in the commit message.**
  "Patches CVE-2024-XXXXX" or "Fixes crash on startup" is helpful.
  "Updated to latest" is not.

## Code review tips

- **Reviewers:** Focus on correctness, security, and clarity. Don't
  argue about style -- that's what linters are for.
- **Authors:** Assume good faith. "Why this approach?" is a question,
  not a criticism. Answer with the trade-offs you considered.
- **Everyone:** Be specific. "This looks wrong" doesn't help anyone.
  "This could return null when X is empty -- see line 47" does.
