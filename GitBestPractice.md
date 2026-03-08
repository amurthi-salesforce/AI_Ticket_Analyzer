# Git & GitHub Best Practices for Salesforce Package Repositories

**Last Updated:** March 8, 2026  
**Project:** AI Ticket Analyzer Package

---

## Repository Structure Guidelines

### One Package = One Repository

**✅ CORRECT:**
```
AI_Ticket_Analyzer/           ← Dedicated repo for one package
├── force-app/
├── manual-setup/
├── config/
├── scripts/
├── sfdx-project.json
└── README.md
```

**❌ INCORRECT:**
```
LukeORG/                      ← Multi-project workspace
├── ai-ticket-analyzer/       ← Package 1
├── DocumentAnalyzer/         ← Package 2
├── force-app/                ← Shared components
└── context.md                ← Development notes
```

**Why:** Package repositories should contain ONLY the distributable package, not the entire development workspace.

---

## Setting Up a Package Repository

### Step 1: Create Clean Package Directory

```bash
# In your development workspace
cd ~/projects/LukeORG

# The package should already be in its own directory
ls ai-ticket-analyzer/
# Should show: force-app/, manual-setup/, config/, sfdx-project.json, README.md
```

### Step 2: Initialize Git in Package Directory

**Option A: New Repository (Recommended)**

```bash
# Navigate to the package directory
cd ai-ticket-analyzer/

# Initialize git (if not already initialized)
git init

# Add package files only
git add .

# Create initial commit
git commit -m "Initial release: AI Ticket Analyzer v1.0.0"

# Create GitHub repo (via web or CLI)
gh repo create amurthi-salesforce/AI_Ticket_Analyzer --public

# Set remote and push
git remote add origin https://github.com/amurthi-salesforce/AI_Ticket_Analyzer.git
git branch -M main
git push -u origin main
```

**Option B: Clean Up Existing Repository**

If you accidentally pushed from the parent directory:

```bash
cd ~/projects/LukeORG

# Remove files that shouldn't be in package repo
git rm -r --cached context.md UIBestPractice.md force-app/ .vscode/ .husky/
git rm -r --cached DocumentAnalyzer/ LWC_DEVELOPMENT_LEARNINGS.md

# Keep only package directory contents
# Move package contents to root if desired
git mv ai-ticket-analyzer/* ./
git mv ai-ticket-analyzer/.* ./ 2>/dev/null || true
git rm -r ai-ticket-analyzer/

# Commit cleanup
git commit -m "Restructure: Keep only AI Ticket Analyzer package contents"

# Force push to clean remote
git push origin main --force
```

---

## Working with Remotes

### Understanding Remotes

A git **remote** is a pointer to a repository on GitHub (or another server).

```bash
# View current remotes
git remote -v
# Output:
# origin  https://github.com/user/repo.git (fetch)
# origin  https://github.com/user/repo.git (push)
```

### Common Remote Issues

#### Issue 1: Wrong Remote URL

**Problem:** Working in LukeORG directory but remote points to package repo

```bash
# Check where you are
pwd
# /Users/amurthi/Salesforce VSCode/LukeORG  ← Parent workspace

# Check remote
git remote -v
# origin  https://github.com/user/AI_Ticket_Analyzer.git  ← Package repo!
```

**Solution:** Either change directory or fix remote

```bash
# Option 1: Work in correct directory
cd ai-ticket-analyzer/
git remote -v  # Should point to AI_Ticket_Analyzer

# Option 2: Change remote (if in wrong directory)
git remote set-url origin https://github.com/user/LukeORG.git
```

#### Issue 2: Multiple Projects, One Remote

**Problem:** Pushing changes from parent directory includes all subdirectories

**Solution:** Use separate git repositories

```bash
# Parent directory (development workspace)
cd ~/projects/LukeORG
git init  # Separate .git directory
git remote add origin https://github.com/user/LukeORG-private.git

# Package directory (for distribution)
cd ai-ticket-analyzer/
git init  # Its own .git directory
git remote add origin https://github.com/user/AI_Ticket_Analyzer.git
```

**Check which repo you're in:**
```bash
git remote -v  # Always verify before push!
git branch --show-current  # Check current branch
git log --oneline -3  # Verify recent commits
```

---

## Staging & Committing Best Practices

### Be Explicit with `git add`

**❌ AVOID:**
```bash
git add .              # Adds EVERYTHING in current directory
git add -A             # Adds all changes in entire repo
git commit -a          # Auto-stages all tracked files
```

**✅ RECOMMENDED:**
```bash
# Add specific files
git add ai-ticket-analyzer/README.md
git add ai-ticket-analyzer/force-app/

# Add specific directories
git add manual-setup/

# Review what's staged
git status

# Review actual changes
git diff --cached

# Then commit
git commit -m "Add FSL Mobile setup classes"
```

### Pre-Commit Checklist

Before every commit:

```bash
# 1. Verify you're in the right directory
pwd

# 2. Check which repo you're working with
git remote -v

# 3. See what will be committed
git status

# 4. Review actual changes
git diff --cached

# 5. Ensure no sensitive files
git ls-files | grep -E '\.env|credentials|secrets|password'

# 6. Commit with clear message
git commit -m "Clear description of changes"

# 7. Push to correct remote
git push origin main
```

---

## .gitignore Best Practices

Create a `.gitignore` at the package root:

```gitignore
# Salesforce
.sfdx/
.sf/
.localdevserver/
node_modules/

# IDE
.vscode/settings.json
.idea/
*.iml
.DS_Store

# Sensitive
.env
.env.local
**/credentials.json
**/*password*
**/*secret*

# Development
context.md
learnings.md
notes/
temp/
scratch/

# Other Projects (if working in parent dir)
/DocumentAnalyzer/
/other-project/
```

**Test your .gitignore:**
```bash
git status --ignored
```

---

## Safe Pushing Practices

### Always Verify Before Push

```bash
# 1. See what will be pushed
git log origin/main..HEAD

# 2. See file changes
git diff origin/main..HEAD --name-status

# 3. If looks good, push
git push origin main

# 4. If something's wrong, don't force push yet!
# Instead, fix locally and push again
```

### When to Force Push

**✅ Safe to Force Push:**
- Cleaning up a new repository
- Your personal/private branch
- You're the only contributor
- You're fixing a mistake immediately after pushing

**❌ Never Force Push:**
- Shared main/master branch with other contributors
- After others have pulled your commits
- Production branches
- Without checking with team first

**Force Push Command:**
```bash
# Standard force push
git push origin main --force

# Safer force push (fails if remote has new commits)
git push origin main --force-with-lease
```

---

## Package Release Workflow

### Recommended Git Flow for Packages

```bash
# 1. Start in your package directory
cd ~/projects/LukeORG/ai-ticket-analyzer/

# 2. Make changes to package
# Edit files...

# 3. Create package version
sf package version create --package "AI Ticket Analyzer" --wait 20

# 4. Test package
sf package install --package 04tXXXXXXXXXXXX --target-org test-org

# 5. Promote to production
sf package version promote --package 04tXXXXXXXXXXXX

# 6. Update README with new package ID
vim README.md  # Update installation URL

# 7. Commit and push
git add README.md sfdx-project.json
git commit -m "Release v1.1.0-1: Update installation links"
git push origin main

# 8. Create GitHub release tag
git tag v1.1.0-1
git push origin v1.1.0-1
```

---

## Multiple Repository Setup

### Managing Development Workspace + Package Repos

**Directory Structure:**
```
~/projects/
├── LukeORG/                      ← Development workspace (private repo)
│   ├── .git/                     ← LukeORG git repo
│   ├── ai-ticket-analyzer/       ← Package subdirectory (NO .git here)
│   ├── DocumentAnalyzer/         ← Another package
│   ├── force-app/                ← Shared dev components
│   ├── context.md                ← Development notes
│   └── README.md                 ← Workspace README
│
└── packages/                     ← Distribution packages (public repos)
    ├── AI_Ticket_Analyzer/       ← Standalone package repo
    │   └── .git/                 ← Its own git repo
    └── DocumentAnalyzer/         ← Another standalone repo
        └── .git/
```

**Workflow:**

```bash
# 1. Develop in workspace
cd ~/projects/LukeORG/ai-ticket-analyzer/
# Make changes...

# 2. When ready for release, sync to package repo
cd ~/projects/packages/AI_Ticket_Analyzer/

# Copy updated files from development
rsync -av --exclude='.git' \
  ~/projects/LukeORG/ai-ticket-analyzer/ \
  ~/projects/packages/AI_Ticket_Analyzer/

# 3. Commit and push package repo
git add .
git commit -m "Release v1.1.0-1"
git push origin main

# 4. Optionally commit workspace changes too
cd ~/projects/LukeORG/
git add ai-ticket-analyzer/
git commit -m "Update ai-ticket-analyzer to v1.1.0-1"
git push origin main
```

---

## Common Mistakes & Fixes

### Mistake 1: Pushed Wrong Files

**Fix with new commit:**
```bash
git rm --cached unwanted-file.md
git commit -m "Remove unwanted file"
git push origin main
```

**Fix by rewriting history (if just pushed):**
```bash
git reset HEAD~1  # Undo last commit, keep changes
git reset --hard HEAD~1  # Undo and discard changes
git push origin main --force-with-lease
```

### Mistake 2: Committed Secrets

**Immediate action:**
```bash
# Remove from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret.env" \
  --prune-empty --tag-name-filter cat -- --all

# Force push
git push origin --force --all

# Rotate the exposed secrets immediately!
```

### Mistake 3: Wrong Commit Message

**Fix most recent commit:**
```bash
git commit --amend -m "New correct message"
git push origin main --force-with-lease
```

### Mistake 4: Pushed to Wrong Branch

**Fix:**
```bash
# Create correct branch from current state
git branch correct-branch

# Reset wrong branch to before mistake
git reset --hard origin/wrong-branch

# Push both
git push origin wrong-branch --force-with-lease
git push origin correct-branch
```

---

## Key Takeaways

1. **One Package = One Repository:** Don't mix workspace and distribution repos
2. **Be Explicit:** Never use `git add .` without reviewing `git status` first
3. **Always Verify:** Check `git remote -v` and `pwd` before pushing
4. **Use .gitignore:** Exclude development files from package repos
5. **Separate Concerns:** Development workspace (private) vs Distribution package (public)
6. **Check Before Push:** Use `git log origin/main..HEAD` to see what will be pushed
7. **Tag Releases:** Use git tags for package versions (`v1.1.0-1`)
8. **Never Commit Secrets:** Use .gitignore and check with `git diff` before commit

---

## Quick Reference

```bash
# Pre-Push Checklist
pwd                                    # Where am I?
git remote -v                          # Which repo?
git status                             # What's staged?
git log origin/main..HEAD --oneline    # What will be pushed?
git push origin main                   # Push!

# Emergency: Undo Last Push
git reset --hard HEAD~1
git push origin main --force-with-lease

# Clean Up Repository
git rm --cached unwanted-file
git commit -m "Remove unwanted file"
git push origin main
```

---

**Created:** March 8, 2026  
**For:** AI Ticket Analyzer Package Development
