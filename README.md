# actions-image-cicd
This repository contains Reusable GitHub Actions Workflows
that can be called by other GitHub Actions Workflows to
reduce duplication, effort, and risk.

These reusable actions are primarily designed to be used
in another repository's Continuous Integration/Continuous Deployment
(CI/CD) where the image is the deployable artifact.

These reusable actions support multi-platform images.

See [GitHub's Documentation on Reusable Actions](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
and the gist [The Basics of GitHub Actions Reusable Workflows](https://gist.github.com/brianjbayer/a1e73789fa26deda500c829d1b4d0d88).

## Reusable Workflows and Actions

### Reusable Workflows

#### buildx_push_image.yml
Idempotent multi-platform image build and push workflow.

**Inputs:**
- `image` - Name of the image to build and push (required)
- `platforms` - Image platforms to build (required)
- `buildopts` - Optional docker buildx options
- `runner` - Type of runner (default: ubuntu-latest)

**Secrets:**
- `registry_u` - Docker registry username
- `registry_p` - Docker registry password/PAT

#### copy_image.yml
Copies/promotes an image from one tag to another.

**Inputs:**
- `from_image` - Source image to copy from (required)
- `to_image` - Target image to copy to (required)
- `runner` - Runner type (default: ubuntu-latest)

**Secrets:**
- `registry_u` - Docker registry username
- `registry_p` - Docker registry password/PAT

#### delete_docker_hub_repositories.yml
Matrix-based deletion of Docker Hub repositories.

**Inputs:**
- `repositories` - JSON array of repository names to delete (required)
- `runner` - Runner type (default: ubuntu-latest)
- `summary` - Add summary report (default: true)
- `ref` - Git reference for action checkout (optional)

**Secrets:**
- `registry_u` - Docker registry username
- `registry_p` - Docker registry password/PAT

#### get_merged_branch_last_commit.yml
Gets merged branch and last commit information.

**Outputs:**
- `merged_branch` - The name of the merged branch
- `last_commit` - The SHA of the last commit

#### image_names.yml
Image name normalization and validation.

**Inputs:**
- `name_base` - Base name for the image (required)
- `branch` - Branch name for tag (required)

**Outputs:**
- `normalized_name` - Docker-compatible normalized image name

### Actions (Dockerfile-based)

#### delete-docker-hub-repository
Container action to delete a Docker Hub repository.

**Inputs:**
- `docker-hub-repository` - Repository name to delete (required)
- `docker-hub-username` - Docker Hub username (required)
- `docker-hub-password` - Docker Hub password/token (required)

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

Examples of using and calling the reusable workflows in this repository
can be found in the _Checks_ for this repository.  See...
  * [.github/workflows/on_pr_checks.yml](https://github.com/brianjbayer/actions-image-cicd/blob/main/.github/workflows/on_pr_checks.yml)

  * [.github/workflows/on_push_merge_checks.yml](https://github.com/brianjbayer/actions-image-cicd/blob/main/.github/workflows/on_push_merge_checks.yml)


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

The image names in this intended CI are tagged with the commit
and can be based upon the PR branch.  While this branch and
commit information is easily available in GitHub PR Actions,
it is not so available in the Push (i.e. merge) Actions.

> :eyes: To ensure that the branch-based image names are valid and
> meet Docker's image name restrictions, use the
> `image_names.yml` reusable workflow.  If the image
> names are not valid, the images will not build and the CI/CD will
> fail.

With this intended CI/CD, there are two basic GitHub Actions workflows...
  * **On Pull Request...**
    1. Build and push unvetted potential release candidate image from
       commit using:
       ```
       .github/workflows/buildx_push_image.yml@v0.2.0
       ```
    2. Pull and perform vetting (e.g. linting, security scans,
       unit tests, end-to-end tests etc) on pushed unvetted potential
       release candidate image
    3. If all vetting checks passed, promote the unvetted potential
       release candidate image to an actual release candidate image
       using:
       ```
       .github/workflows/copy_image.yml@v0.2.0
       ```

  * **On Push to main (merge)...**
    1. Get the merged branch and the last commit of it to determine
      the release candidate image name using:
       ```
       .github/workflows/get_merged_branch_last_commit.yml@v0.2.0
       ```
    2. Promote the release candidate image to production using:
       ```
       .github/workflows/copy_image.yml@v0.2.0
       ```
    3. Optionally tag the just promoted production image as latest
       using:
       ```
       .github/workflows/copy_image_to_latest.yml@v0.2.0
       ```

For more on image-based CI/CD, see the gist
[An Image-Based Continuous Integration / Continuous Deployment Model](https://gist.github.com/brianjbayer/e5e9f07e0923d8d097d7b03803ea837b).

## Testing
When modifying/developing workflows in this repository, changes should
be on a branch in this repository and tested (especially merge/on push
related workflows) using another test bed repository to call these
workflows.
