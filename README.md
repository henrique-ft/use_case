![PhoenixUp](https://raw.githubusercontent.com/henriquefernandez/use_case/master/priv/static/logo_small.png)

# UseCase

A different approach for Elixir projects structure.

```elixir
defmodule SayHello do
  @moduledoc """
    My great use case
  """
  use UseCase,
    input: [:name],
    output: [:message]

  def call(%{name: name}, _opts), do: ok(message: "Hello #{name}!")
end

UseCase.call %SayHello{name: "Henrique"}
# {:ok, %SayHello.Output{message: "Hello Henrique!"}}
```

## Installation

The package can be installed by adding `use_case` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:use_case, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/use_case](https://hexdocs.pm/use_case).

