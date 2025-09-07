# Create minimal Rocker image for codespace
# https://github.com/rocker-org/devcontainer-images/pkgs/container/devcontainer%2Ftidyverse
ARG VARIANT="4"
FROM ghcr.io/rocker-org/devcontainer/tidyverse:${VARIANT}

# Install Ubuntu package to suppress R plot warning
RUN apt-get -y update && apt-get install -y --no-install-recommends libxt6
