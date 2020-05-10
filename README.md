![PhoenixUp](https://raw.githubusercontent.com/henriquefernandez/use_case/master/priv/static/small_logo.png)

# UseCase

A way to increase *Elixir* projects readability and maintenance based on *Use Cases* and *Interactors*, the main goals are:

- Single Responsability Principle
- Composability
- Readability
- Screaming architecture
- Enforce inputs and outputs of our project use cases
- Better errors (Know exactly where our code fails)
- Standardization

## Installation

The package can be installed by adding `use_case` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:use_case, "~> 0.1.2"}
  ]
end
```

## Creating a basic interactor

The most basic interactor can be created using the `UseCase.Interactor` module, defining an `output` for it and creating a `call/2` function:

```elixir
defmodule SayHello do
  use UseCase.Interactor,
    output: [:message]

  def call(%{name: name}, _opts), do: ok(message: "Hello #{name}!")
  def call(%{name: nil}, _opts), do: error("name is obrigatory")
end
```

Now our `SayHello` module has the `ok` and `error` macros and a struct for `Output` like `%SayHello.Output{message: "something"}`

The `ok` and `error` macro can be used to define when our interactor `success` or `fail`

After define, we can call it in many ways:

```elixir
iex> UseCase.call(SayHello, %{name: "Henrique"}) 
iex> {:ok, SayHello.Output{message: "Hello Henrique!", _state: nil}}

iex> UseCase.call!(SayHello, %{name: "Henrique"}) 
iex> SayHello.Output{message: "Hello Henrique!", _state: nil}

iex> SayHello.call(%{name: "Henrique"})
iex> {:ok, SayHello.Output{message: "Hello Henrique!", _state: nil}}

iex> UseCase.call(SayHello, %{name: nil}) 
iex> {:error, SayHello.Error{message: "name is obrigatory!"}}

iex> UseCase.call!(SayHello, %{name: nil}) 
iex> **** SayHello.Error name is obrigatory!
```

### Defining an input

Sometimes we want to guarantee the inputs our interactors will receive, we can do it defining this way:  

```elixir
defmodule SayHello do
  use UseCase.Interactor,
    output: [:message],
    input: [:name] # Add this 

  def call(%SayHello{name: name}, _opts), do: ok(message: "Hello #{name}!")
  def call(%SayHello{name: nil}, _opts), do: error("name is obrigatory")
end
```

Now, with `UseCase` module we can call it using the input directly:

```elixir
iex> UseCase.call %SayHello{name: "Henrique"} 
iex> {:ok, SayHello.Output{message: "Hello Henrique!"}}

iex> UseCase.call! %SayHello{name: "Henrique"} 
iex> SayHello.Output{message: "Hello Henrique!"}
```

### Adding more information for errors

We can add more information for errors this way:  

```elixir
defmodule SayHello do
  use UseCase.Interactor,
    output: [:message],
    input: [:name],
    error: [:code]

  def call(%SayHello{name: name}, _opts), do: ok(message: "Hello #{name}!")
  def call(%SayHello{name: nil}, _opts), do: error("name is obrigatory", code: 500) # And use it
end
```

```elixir
iex> UseCase.call(SayHello, %{name: nil}) 
iex> {:error, SayHello.Error{message: "name is obrigatory!", code: 500}}
```

### Default fields
When not defined input, output and error defaults to:

```
input: [:_state],
output: [],
error: [:message]
```

Fields `:_state` in `input` and `:message` in `error` are always appended. The `:_state` field is very useful for pipe operations

### Composing with `UseCase.pipe` and `UseCase.pipe!`

We can compose interactors simple as that:

```elixir
defmodule LogOperation do
  use UseCase.Interactor

  def call(%{message: message}, _opts) do
    # .. log message
    ok()
  end
end
```

```elixir
iex> UseCase.pipe [%SayHello{name: "Henrique"}, LogOperation] 
iex> {:ok, LogOperation.Output{_state: nil}}

iex> UseCase.pipe [%SayHello{name: nil}, LogOperation] 
iex> {:error, SayHello.Error{message: "name is obrigatory!", code: 500}}
```

## Contribute

*UseCase* is not only for me, but for the *Elixir* community.

I'm totally open to new ideas. Fork, open issues and feel free to contribute with no bureaucracy. We only need to keep some patterns to maintain an organization:

#### branchs

*your_branch_name*

#### commits

*[your_branch_name] Your commit*
