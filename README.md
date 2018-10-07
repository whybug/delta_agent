# Delta Agent

The Delta Agent is a piece of software that runs in your infrastructure. Its job is
to collect GraphQL operations and bring them to Delta in a performant manner.

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

## Inspiration

- https://github.com/timberio/timber-elixir/blob/master/lib/timber/logger_backends/http.ex
- https://github.com/scoutapp/scout_apm_elixir/blob/master/lib/scout_apm/store.ex
