#============
# Build Stage
#============
FROM bitwalker/alpine-elixir:1.7 as build

# Copy the source folder into the Docker image
WORKDIR /build
COPY . .

# Install dependencies and build Release
RUN export MIX_ENV=prod && \
  rm -Rf _build && \
  mix deps.get && \
  mix release

# Extract Release archive to /rel for copying in next stage
RUN APP_NAME="delta_agent" && \
  RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
  mkdir /export && \
  tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#=================
# Deployment Stage
#=================
FROM pentacent/alpine-erlang-base:21
WORKDIR /opt/app

# Set environment variables and expose port
EXPOSE 4000
ENV MIX_ENV=prod \
  REPLACE_OS_VARS=true \
  PORT=4000

# Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /build/_build/${MIX_ENV}/rel/* ./

# Change user
USER default

# Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/delta_agent"]
CMD ["foreground"]