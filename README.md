# actions-image-cicd
This repository contains Reusable GitHub Actions Workflows
that can be called by other GitHub Actions Workflows to
reduce duplication, effort, and risk.

These reusable actions are primarily designed to be used
in another repository's Continuous Integration/Continuous Deployment
(CI/CD) where the image is the deployable artifact.

See [GitHub's Documentation on Reusable Actions](https://docs.github.com/en/actions/using-workflows/reusing-workflows).

## Intent of the Workflows
These workflows were designed to be simple cohesive building blocks called
within the using repository's own customized workflows where the high-level
logic is.

## Using These Reusable Workflows
> :warning: the `.github/workflows/on_*_checks.yml` workflows are
> **not** reusable.

You can directly use the reusable workflows in this public repository per
The GitHub Actions
[Access to Reusable Workflows Documentation](https://docs.github.com/en/actions/using-workflows/reusing-workflows#access-to-reusable-workflows)

Examples of using the reusable workflows in this repository can be found
in the _Checks_ for this repository which call the reusable workflows.

See...
```
.github/workflows/on_pr_checks.yml
```
and
```
.github/workflows/on_push_merge_checks.yml
```

## Intended CI/CD Flow
These workflows were developed specifically for a CI/CD flow where a commit
image is considered the release candidate image.  If the image passes all
automated CI checks and tests, then it is promoted as a release candidate.

Deployment of the release candidate image to production is considered a
separate event allowing for canary or blue-green deploys.  If the
candidate image deployment is successful, then a webhook from that
deployment system triggers the merge in the code repository which
does the official image promotion to the production image and could
also trigger the (re)deployment of this production-named image to
production.

The image names in this intended CI are based upon the PR Branch and
tagged with the commit.  While this information is easily available
in GitHub PR Actions it is not so available in the Push (i.e. merge)
Actions.

With this intended CI/CD, there are two basic GitHub Actions workflows...
  * **On Pull Request...**
    1. Build and push unvetted potential release candidate image from
       commit using:
       ```
       .github/workflows/build_push_image.yml@main
       ```
    2. Pull and perform vetting (e.g. linting, security scans, 
       unit tests, end-to-end tests etc) on pushed unvetted potential
       release candidate image
    3. If all vetting checks passed, promote the unvetted potential
       release candidate image to an actual release candidate image
       using:
       ```
       .github/workflows/pull_push_image.yml@main
       ```

  * **On Push to main (merge)...**
    1. Get the merged branch and the last commit of it to determine
      the release candidate image name using:
       ```
       .github/workflows/get_merged_branch_last_commit.yml@main
       ```
    2. Promote the release candidate image to production using:
       ```
       .github/workflows/pull_push_image.yml@main
       ```
    3. Optionally tag the just promoted production image as latest
       using:
       ```
       .github/workflows/pull_push_latest_image.yml@main
       ```

## Testing
When modifying/developing workflows in this repository, changes should
be on a branch in this repository and tested (especially merge/on push
related workflows) using another test bed repository to call these
workflows).
