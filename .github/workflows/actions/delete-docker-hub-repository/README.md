# Delete Docker Hub Repository

Deletes a Docker Hub repository using the Docker Hub v2 API. The action packages a small Ruby script and a Dockerfile to run it inside a container.

This action expects the repository name and Docker Hub credentials as inputs; it authenticates, verifies the repository exists, and issues a delete request.

## Files
- `action.yml` — action metadata (inputs + docker runner)
- `Dockerfile` — container image used to run the script
- `delete-docker-hub-repository.rb` — Ruby implementation that calls the Docker Hub API

## Inputs
- `docker-hub-repository` (required) — repository name under the Docker Hub account to delete (e.g., `my-repo`)
- `docker-hub-username` (required) — Docker Hub username
- `docker-hub-password` (required) — Docker Hub password or access token

These inputs are mapped to the following environment variables inside the container:
- `DOCKER_HUB_REPOSITORY`
- `DOCKER_HUB_USERNAME`
- `DOCKER_HUB_PASSWORD`

## Example usage (in the same repo)
```yaml
- name: Delete Docker Hub repository
  uses: ./.github/workflows/actions/delete-docker-hub-repository
  with:
    docker-hub-repository: my-repo
    docker-hub-username: ${{ secrets.DOCKER_HUB_USERNAME }}
    docker-hub-password: ${{ secrets.DOCKER_HUB_PASSWORD }}
```

## Run locally (build & run container)
Build:
```sh
docker build -t delete-docker-hub-repo .github/workflows/actions/delete-docker-hub-repository
```
Run:
```sh
docker run --rm \
  -e DOCKER_HUB_USERNAME=your_user \
  -e DOCKER_HUB_PASSWORD=your_token \
  -e DOCKER_HUB_REPOSITORY=repo_to_delete \
  delete-docker-hub-repo
```

## Behavior and notes
- Authenticates via `POST /v2/users/login/` to obtain a token, checks repository existence with `GET /v2/repositories/{user}/{repo}/`, and deletes with `DELETE /v2/repositories/{user}/{repo}/`.
- Prefer Docker Hub access tokens over account passwords. Provide credentials via repository/organization secrets.
- No outputs are produced by the action; logs include status messages and HTTP responses to aid debugging.

## Troubleshooting
- Ensure the inputs/secret names are correct and the authenticated user has permission to delete the repository.
- If the repository is not found, the script will stop and log the 404 response from Docker Hub.

## License
Follow the repository license in the project root.
```// filepath: .github/workflows/actions/delete-docker-hub-repository/README.md
