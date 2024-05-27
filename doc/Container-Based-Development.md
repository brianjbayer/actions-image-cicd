## General Container-Based Development
For most feature development activities that
only involve changes to the application code
you do not need to rebuild the image.  However,
if you need to make changes to the application
infrastructure like dependencies, versions,
`Dockerfile`, you will need to rebuild the
image to ensure that it still builds and works.

Container-based development offers the benefit
of consistency and fast (no native) setup, but
that comes with the tradeoff of ensuring that
**ALL** of the project build files are consistent
with the project's `Dockerfile` and image building.

For instance for a Ruby/Rails project...
* Ruby version in `Gemfile` and `Gemfile.lock`
* Platforms for multi-platform `bundle` in `Gemfile.lock`
* Bundler version in `Gemfile.lock`

The easiest way to manage all of this is to
develop and update your project in its containerized
development environment.

> :book: To add a Development Environment image to your application, see
> [Dockerfile: Build the Right Machine for Your App](https://gist.github.com/brianjbayer/9c358218fa76d7d5491299e2760fd0ed)

Given you are operating in your containerized development
environment, here are some recipes for doing common
Ruby maintenance activities in a container-first way.

### Update Gems
To minimize changes to your `Gemfile.lock` if it
has expected platforms etc., `bundle update` your
project in the containerized environment.  This
avoids rebuilding the `Gemfile.lock` and having
to manually add any platforms or other directives

1. Start you containerized development environment

2. [Update](https://bundler.io/v1.13/man/bundle-update.1.html) your gems...
   ```
   bundle update
   ```

   or a specific gem, for example...
   ```
   bundle update nokogiri
   ```

3. Rebuild your image with the new gems to ensure it builds

#### Updated Files
1. `Gemfile.lock`

### Update Bundler Version
Assuming that you are following Ruby `Dockerfile` best-fit
practices, you will have your `bundler` version in both
your `Gemfile.lock` and in your `Dockerfile`.

1. Start you containerized development environment

2. Install the desired version of `bundler` in your
   containerized development environment, for example...
   ```
   gem install bundler:2.5.10
   ```

   or to install latest version...
   ```
   gem install bundler
   ```

   > :bulb: if you are using one of the
   > [official Ruby Docker Images](https://hub.docker.com/_/ruby),
   > you can set the environment variable `BUNDLER_VERSION` to
   > set the system (default) version of bundler
   > (e.g. `BUNDLER_VERSION=2.5.6`)

3. ["Update the locked version of bundler to the invoked bundler version"](https://bundler.io/v2.0/man/bundle-update.1.html#OPTIONS)
   using the installed bundle version
   ```
   bundle _<BUNDLER-VERSION>_ update --bundler
   ```

   for example...
   ```
   bundle _2.5.10_ update --bundler
   ```

4. Update the Bundler version in your `Dockerfile`, for example...
   ```dockerfile
   ...
   # Use the same version of Bundler in the Gemfile.lock
   ARG BUNDLER_VERSION=2.5.6
   ENV BUNDLER_VERSION=${BUNDLER_VERSION}
   ...
   RUN apt-get update \
     ...
     && gem install bundler:${BUNDLER_VERSION}
   ```

5. Rebuild your image with the new `bundler` version
   to ensure it builds

#### Updated Files
1. `Gemfile.lock`
2. `Dockerfile`

### Update Ruby Version
Assuming that you are following Ruby `Dockerfile` best-fit
practices, you will have your `bundler` version in both
your `Gemfile` (and `Gemfile.lock`) and in your `Dockerfile`.

1. Edit your `Gemfile` and update your Ruby version,
   for example to update to `3.2.4`...
   ```gemfile
   # frozen_string_literal: true

   source 'https://rubygems.org'

   ruby '3.2.4'
   ```

2. Edit your `Dockerfile` and update your Ruby version,
   for example to update to `3.2.4`...
   ```dockerfile
   #--- Base Image ---
   ARG BASE_IMAGE=ruby:3.2.4-slim-bookworm
   FROM ${BASE_IMAGE} AS ruby-base
   ```

3. Build your updated containerized development
   image environment with the updated ruby version

4. Start you containerized development environment
   with your new updated image

5. Run the bundle command to update your Ruby
   version in the `Gemfile.lock`....
   ```
   bundle update --ruby
   ```

6. Rebuild your image with the new version
   to ensure it builds

#### Updated Files
1. `Gemfile`
2. `Dockerfile`
3. `Gemfile.lock`
4. `.ruby-version` (optional native)
5. Documentation such as README (optional)
