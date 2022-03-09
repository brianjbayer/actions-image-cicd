# This Dockerfile is so that the image-based
# reusable workflows here can be
# run by checks in this repository
# aka "dogfooding"

FROM alpine:latest
COPY . /actions-image-cicd
WORKDIR /actions-image-cicd
