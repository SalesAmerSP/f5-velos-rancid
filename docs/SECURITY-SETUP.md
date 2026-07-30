# Setting up your new repository

After creating a repo from this template, there are a few settings that
need to be turned on manually. These settings live in GitHub's web
interface (or API), not in files, so the template can't set them
automatically.

**This is a one-time checklist.** Work through it once and you're done.

> **Not comfortable with the command line?** Each step includes both a
> terminal command and instructions for doing it through the GitHub
> website. Use whichever you prefer.

Throughout this guide, replace `<OWNER>/<REPO>` with your actual
GitHub username (or organization name) and repository name. For example,
if your GitHub username is `janedoe` and your repo is called `my-app`,
you'd use `janedoe/my-app`.

---

## Step 1: Enable private vulnerability reporting

This lets security researchers report problems to you privately (instead
of posting them publicly where attackers can see them).

**Using the terminal:**

```bash
gh api -X PUT repos/<OWNER>/<REPO>/private-vulnerability-reporting
```

**Using the website:**

1. Go to your repo on GitHub
2. Click **Settings** (the gear icon tab)
3. In the left sidebar, click **Code security and analysis**
4. Find **Private vulnerability reporting** and turn it on

**Verify it worked:**

```bash
gh api repos/<OWNER>/<REPO>/private-vulnerability-reporting
# You should see: {"enabled":true}
```

---

## Step 2: Enable Dependabot security updates

Dependabot watches your dependencies for known vulnerabilities. This
step turns on *automatic fix PRs* -- when a vulnerability is found,
Dependabot will open a pull request with the fix instead of just
alerting you.

**Using the terminal:**

```bash
gh api -X PUT repos/<OWNER>/<REPO>/automated-security-fixes
gh api -X PUT repos/<OWNER>/<REPO>/vulnerability-alerts
```

**Using the website:**

1. Go to **Settings > Code security and analysis**
2. Enable **Dependabot alerts**
3. Enable **Dependabot security updates**

**Verify it worked:**

```bash
gh api repos/<OWNER>/<REPO>/automated-security-fixes
# You should see: {"enabled":true,"paused":false}
```

---

## Step 3: Protect the main branch

Branch protection prevents mistakes like accidentally pushing broken
code directly to `main`. With this turned on, all changes must go
through a pull request.

**Using the terminal:**

```bash
gh api -X PUT repos/<OWNER>/<REPO>/branches/main/protection \
  --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false
}
JSON
```

> **What does `required_approving_review_count: 0` mean?** It means pull
> requests are required, but you don't need someone else to approve them.
> This is fine for solo projects. If you have a team, change it to `1`
> (or more) so at least one other person reviews each change.

**Using the website:**

1. Go to **Settings > Branches**
2. Click **Add branch protection rule**
3. Set "Branch name pattern" to `main`
4. Check **Require a pull request before merging**
5. Uncheck **Allow force pushes** and **Allow deletions**
6. Click **Create**

---

## Step 4 (optional): Require signed commits

> **Only do this after you and your contributors have set up commit
> signing.** See [CONTRIBUTING.md](../CONTRIBUTING.md#commit-signing)
> for how. If you turn this on before signing is set up, you (and
> everyone else) will be unable to push to `main`.

Signed commits prove that a commit really came from the person it says
it came from, not someone who stole their credentials.

**Using the terminal:**

```bash
# Turn it on:
gh api -X POST repos/<OWNER>/<REPO>/branches/main/protection/required_signatures

# If you need to turn it off (locked yourself out):
gh api -X DELETE repos/<OWNER>/<REPO>/branches/main/protection/required_signatures
```

**Using the website:**

1. Go to **Settings > Branches**
2. Edit the `main` branch protection rule
3. Check **Require signed commits**
4. Save

---

## Step 5 (optional): Enable Discussions

If you want a Q&A or discussion space separate from your issue tracker:

**Using the terminal:**

```bash
gh api -X PATCH repos/<OWNER>/<REPO> -F has_discussions=true
```

**Using the website:**

1. Go to **Settings > General**
2. Scroll down to **Features**
3. Check **Discussions**

> If you don't enable Discussions, you should remove the "Question or
> discussion" link from `.github/ISSUE_TEMPLATE/config.yml` so people
> don't see a broken link.

---

## Step 6: Replace the template placeholders

The template has placeholder text that you need to replace with your
project's real values. Run this command to find them all:

```bash
grep -rn "<TEMPLATE" .
```

You'll find placeholders like:

- `<TEMPLATE-OWNER>` and `<TEMPLATE-REPO>` -- replace with your
  GitHub username/org and repo name

---

## Step 7: Choose which dependency ecosystems to monitor

The file [.github/dependabot.yml](../.github/dependabot.yml) comes
with GitHub Actions monitoring turned on. For your project's own
dependencies, uncomment the section for your language(s):

- Python (`pip`)
- JavaScript/Node.js (`npm`)
- Go (`gomod`)
- Rust (`cargo`)
- Ruby (`bundler`)
- Java (`maven`)
- .NET (`nuget`)
- Terraform (`terraform`)
- PHP (`composer`)

Each section has a `directory` field -- set it to the folder where your
package manifest lives (usually `/` for the root of the repo).

---

## Step 8: Pin your dependencies

"Pinning" means locking every library your project uses to a specific
version. This prevents a compromised or buggy update from silently
breaking your project.

| Language | How to create the lock file | How to install from it |
|---|---|---|
| Python | `pip-compile --generate-hashes requirements.in` | `pip install --require-hashes -r requirements.txt` |
| Node.js | `npm install` | `npm ci` |
| Go | `go mod tidy && go mod download` | `go mod verify` |
| Rust | `cargo build` | `cargo build --locked` |
| Ruby | `bundle install` | `bundle install --frozen` |

**Commit the lock file to your repo.** Without it, Dependabot has
nothing to track and no way to verify package integrity.

---

## Step 9: Test that everything works

Push a small test change (like editing the README) as a pull request
and verify:

- [ ] The PR template appeared and has the checklist
- [ ] The Gitleaks secret scan ran
- [ ] Branch protection stopped you from pushing directly to `main`

If anything didn't work, the most likely cause is that the corresponding
setting from this checklist wasn't completed. Go back through the steps
above and double-check.

---

## Quick setup script

If you're comfortable with the terminal, here's a script that does
steps 1-3 in one shot. Replace `<OWNER>/<REPO>` with your values
before running it.

```bash
#!/bin/bash
set -euo pipefail
REPO="<OWNER>/<REPO>"

echo "==> Enabling private vulnerability reporting ..."
gh api -X PUT "repos/${REPO}/private-vulnerability-reporting"

echo "==> Enabling Dependabot security updates ..."
gh api -X PUT "repos/${REPO}/automated-security-fixes"
gh api -X PUT "repos/${REPO}/vulnerability-alerts"

echo "==> Setting branch protection on main ..."
gh api -X PUT "repos/${REPO}/branches/main/protection" --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false
}
JSON

echo ""
echo "==> Done! Next steps:"
echo "  1. Run: grep -rn '<TEMPLATE' ."
echo "     and replace all placeholders with your real values"
echo "  2. Uncomment the Dependabot ecosystems your project uses"
echo "  3. Pin your dependencies and commit the lock file"
echo "  4. Set up commit signing (see CONTRIBUTING.md)"
echo "  5. Push a test PR to verify everything works"
```
