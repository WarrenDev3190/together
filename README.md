# Together

[![Hex.pm](https://img.shields.io/hexpm/v/together.svg)]()
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/together)

Group actions that can be handled / responded to later together

## What for?

- group notifications to be sent in ONE email
    - cancel the previously queued email if another event happens within a short period (type: debounce)
- make heavy operations happen less often, i.e. refresh some global statistics
    - allow only 1 operation per certain period (type: throttle)
- protect some write api
    - additonally you can choose to use the first value in a period (keep: first)
    - or the last value in the period (keep: last)

## Installation

**Elixir 1.4 is required**

The package can be installed as:

Add `together` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:together, "~> 0.3"}]
end
```

## How to use

Start a `Together.Worker` to use it

You can start it by adding a worker to your app's supervision tree

```elixir
worker(Together.Worker, [[delay: 3000, type: :debounce], [name: Together.Worker]])
```

Or start it as you would any other GenServer

```elixir
{:ok, pid} = Together.Worker.start_link(delay: 30_000, type: :throttle)
```

Make calls to the worker process:

```elixir
Together.process(binary_name, "somethiny_unique", some_func)
Together.process(pid, "some_unique_name_or_id", a_function)
Together.process(Together.Worker, "id", Module, :func, [arg1, arg2, ...])
```

## TODO

- keep: all (seems to be touching `gen_stage` territory)
