#--- Base Image ---
# Ruby version must match that in Gemfile.lock
ARG BASE_IMAGE=ruby:4.0.4-slim-trixie
FROM ${BASE_IMAGE} AS ruby-base

#--- Installer Stage ---
FROM ruby-base AS installer

# Gem versions
ARG OCTOKIT_VERSION=10.0.0
ARG FARADAY_RETRY_VERSION=2.4.0

# Update gem command to latest
RUN gem update --system \
# Install gems
  && gem install \
  "octokit:${OCTOKIT_VERSION}" \
  "faraday-retry:${FARADAY_RETRY_VERSION}"

WORKDIR /app

#--- Development Environment Stage ---
# Assume volume mounting
FROM installer AS devenv

# Start devenv in (command line) shell
CMD ["bash"]

#--- Run Action Stage ---
FROM installer AS run-action

# Make the entrypoint script executable
COPY --chmod=0755 merge-commit-pr-info.rb /merge-commit-pr-info.rb

# Set the entrypoint to the script
ENTRYPOINT ["/merge-commit-pr-info.rb"]
