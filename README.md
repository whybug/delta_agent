# Delta Agent

[![CircleCI](https://circleci.com/gh/whybug/delta_agent.svg?style=svg)](https://circleci.com/gh/whybug/delta_agent)

The Delta Agent is a piece of software that runs in your infrastructure. Its job is
to collect GraphQL operation usage and bring them to Delta in a performant manner.

## Requirements

An API key is needed. You find your API key in the web interface under Settings > API Keys.

## Installation using Docker

```
docker run whybug/delta_agent
```

## Installation using Kubernetes Helm

values.yaml

```
chart: whybug/delta_agent
```

## Usage
Sent to Delta Agent:
  !body or hash
  !schema
  !timestamp
  ?client[os]
  ?client[version]
  ?metadata

## Inspiration

- https://github.com/timberio/timber-elixir/blob/master/lib/timber/logger_backends/http.ex
- https://github.com/scoutapp/scout_apm_elixir/blob/master/lib/scout_apm/store.ex
- https://github.com/adrienmo/buffer/blob/master/test/buffer_test.exs
- https://github.com/adrienmo/buffer/blob/master/lib/buffer/write/key_list.ex
