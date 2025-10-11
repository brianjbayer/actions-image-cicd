#--- Base Image ---
ARG BASE_IMAGE=ruby:3.4.6-slim-trixie
FROM ${BASE_IMAGE} AS ruby-base

#--- Run Action Stage ---
# Make the entrypoint script executable
COPY --chmod=0755 delete-docker-hub-repository.rb /delete-docker-hub-repository.rb

# Set the entrypoint to the script
ENTRYPOINT ["/delete-docker-hub-repository.rb"]
