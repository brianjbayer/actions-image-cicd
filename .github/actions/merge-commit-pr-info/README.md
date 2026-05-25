# merge-commit-pr-info

GitHub Action that resolves Pull Request information from a merge commit SHA.

This action is useful in workflows triggered after merges where only the merge commit SHA is available and you need metadata about the merged PR such as:

- PR number
- PR title
- PR URL
- Source (PR) branch
- Target (base) branch
- Last commit on source branch
- Last commit on target branch before merge

The action uses the GitHub API endpoint that associates pull requests with a commit SHA.

---

## Features

- Docker-based GitHub Action
- Uses the GitHub API via Ruby + Octokit
- Works with merge commits
- Exposes PR metadata as workflow outputs
- Minimal runtime dependencies

---

## Inputs

| Name | Required | Description |
|---|---|---|
| `github-owner-repo` | yes | Repository in `owner/repo` format |
| `merge-commit-sha` | yes | Merge commit SHA |
| `github-token` | yes | GitHub token with repository read access |

---

## Outputs

| Output | Description |
|---|---|
| `number` | PR number |
| `title` | PR title |
| `url` | PR URL |
| `branch` | PR source branch (`head.ref`) |
| `last-commit` | Last commit SHA on PR branch |
| `base-branch` | Target branch of merge (`base.ref`) |
| `base-last-commit` | Last commit SHA on base branch before merge |

---

## Usage

### Basic Example

```yaml
name: Resolve PR Info

on:
  push:
    branches:
      - main

jobs:
  pr-info:
    runs-on: ubuntu-latest

    steps:
      - name: Get PR info from merge commit
        id: pr-info
        uses: your-org/merge-commit-pr-info@v1
        with:
          github-owner-repo: ${{ github.repository }}
          merge-commit-sha: ${{ github.sha }}
          github-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Print outputs
        run: |
          echo "PR Number: ${{ steps.pr-info.outputs.number }}"
          echo "PR Title: ${{ steps.pr-info.outputs.title }}"
          echo "PR URL: ${{ steps.pr-info.outputs.url }}"
          echo "PR Branch: ${{ steps.pr-info.outputs.branch }}"
          echo "PR Last Commit: ${{ steps.pr-info.outputs.last-commit }}"
          echo "Base Branch: ${{ steps.pr-info.outputs.base-branch }}"
          echo "Base Last Commit: ${{ steps.pr-info.outputs.base-last-commit }}"
```

---

## Example Outputs

```text
number=42
title=Add authentication middleware
url=https://github.com/acme/api/pull/42
branch=feature/auth-middleware
last-commit=abc123def456
base-branch=main
base-last-commit=987zyx654wvu
```

---

## Local Development

### Prerequisites

- Docker (Desktop) installed and running

---

## Local Test Plan

### 1. Clone Repository

```bash
git clone git@github.com:YOUR_ORG/merge-commit-pr-info.git
cd merge-commit-pr-info
```

---

### 2. Build Docker Image

```bash
docker build -t merge-commit-pr-info .
```

Expected result:

```text
Successfully tagged merge-commit-pr-info:latest
```

---

### 3. Create GitHub Personal Access Token

Create a token with:

- `repo` scope for private repositories
- public repo access for public repositories

Export token:

```bash
export GITHUB_TOKEN=ghp_your_token_here
```

---

### 4. Identify a Merge Commit SHA

Example:

```bash
git log --merges --oneline
```

Copy a merge commit SHA.

Example:

```text
a1b2c3d Merge pull request #42 from feature/example
```

---

### 5. Create Local Output File

GitHub Actions normally injects `GITHUB_OUTPUT`.

Simulate locally:

```bash
touch github-output.txt
```

---

### 6. Run Action Container Locally

```bash
docker run --rm \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GITHUB_OWNER_REPOSITORY="owner/repository" \
  -e MERGE_COMMIT="a1b2c3d4e5f6..." \
  -e GITHUB_OUTPUT="/tmp/github-output.txt" \
  -v "$(pwd)/github-output.txt:/tmp/github-output.txt" \
  merge-commit-pr-info
```

---

### 7. Inspect Outputs

```bash
cat github-output.txt
```

Example:

```text
number=42
title=Add authentication middleware
url=https://github.com/acme/api/pull/42
branch=feature/auth-middleware
last-commit=abc123def456
base-branch=main
base-last-commit=987zyx654wvu
```

---

## Development Environment Container

The Dockerfile includes a development stage named `devenv`.

Start interactive shell:

```bash
docker build --target devenv -t merge-commit-pr-info-dev .
```

Run shell:

```bash
docker run --rm -it \
  -v "$(pwd):/app" \
  merge-commit-pr-info-dev
```

Inside container:

```bash
ruby merge-commit-pr-info.rb
```

---

## Testing Against a Real Repository

Example:

```bash
docker run --rm \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GITHUB_OWNER_REPOSITORY="octocat/Hello-World" \
  -e MERGE_COMMIT="MERGE_SHA_HERE" \
  -e GITHUB_OUTPUT="/tmp/github-output.txt" \
  -v "$(pwd)/github-output.txt:/tmp/github-output.txt" \
  merge-commit-pr-info
```

---

## Error Conditions

The action intentionally fails when:

### No Matching PR Found

```text
No PR found where this SHA is the merge commit!
```

Possible causes:

- SHA is not a merge commit
- commit does not belong to a PR
- wrong repository specified

---

### Multiple Matching PRs

```text
More than one PR with merge commit: Found PR #s [...]
```

This should be extremely rare and indicates ambiguous repository state.

---

## Debugging

Enable verbose Docker output:

```bash
docker run --rm -it \
  --entrypoint bash \
  merge-commit-pr-info
```

Test Ruby script manually:

```bash
ruby /merge-commit-pr-info.rb
```

---
