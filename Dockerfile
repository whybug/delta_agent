# Build image including full Elixir
FROM elixir:1.7.4-alpine as builder
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION} \
    MIX_ENV=prod

WORKDIR /app

# Build tools
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache git build-base && \
  mix local.rebar --force && \
  mix local.hex --force

# Dependencies
COPY mix.* /app/
RUN mix do deps.get --only prod, deps.compile

# Release image
COPY . /app/
RUN mix release --env=prod --no-tar

# Final image with minimal size
FROM alpine:3.8 as runner
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
RUN apk add --no-cache \
  bash \
  ncurses-libs \
  zlib \
  ca-certificates \
  openssl \
  && update-ca-certificates
RUN addgroup -g 1000 whybug && \
  adduser -D -h /app \
  -G whybug \
  -u 1000 \
  whybug
USER whybug
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/delta_agent /app
CMD trap 'exit' INT; /app/bin/delta_agent foreground
