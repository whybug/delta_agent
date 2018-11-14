# Build image including full Elixir
FROM elixir:1.7.4-alpine as builder
RUN apk add --no-cache \
  gcc \
  git \
  make \
  musl-dev
RUN mix local.rebar --force && \
  mix local.hex --force
WORKDIR /app
ENV MIX_ENV=prod

# Dependencies
FROM builder as deps
COPY mix.* /app/
RUN mix do deps.get --only prod, deps.compile

# Release image
FROM deps as releaser
COPY . /app/
RUN mix release --env=prod --no-tar

# Final image with minimal size
FROM alpine:3.8 as runner
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
COPY --from=releaser /app/_build/prod/rel/delta_agent /app
EXPOSE 4000
ENV APP_VERSION=${APP_VERSION}
CMD trap 'exit' INT; /app/bin/delta_agent foreground
