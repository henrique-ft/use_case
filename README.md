![PhoenixUp](https://raw.githubusercontent.com/henriquefernandez/use_case/master/priv/static/small_logo.png)

# UseCase

A way to increase *Elixir* projects readability and maintenance based on *Use Cases* and *Interactors*, the main goals are:

- Single Responsability Principle
- Composability
- Readability
- Screaming architecture
- Enforce inputs and outputs of our project use cases
- Better errors (Know exactly where code fails)
- Standardization

## Table of contents

  - [Installation](#installation)
  - [Interactors](#interactors)
    - [Defining inputs](#defining-inputs)
    - [Defining errors](#defining-errors)
    - [Default fields](#default-fields)
    - [Composing with pipes](#composing-with-pipes)
    - [Sending Options](#sending-options)
  - [Contribute](#contribute)

## Installation

The package can be installed by adding `use_case` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:use_case, "~> 0.1.2"}
  ]
end
```

## Interactors

The most basic interactor can be created using the `UseCase.Interactor` module, defining an `output` for it and creating a `call/2` function:

```elixir
defmodule SayHello do
  use UseCase.Interactor,
    output: [:message]

  def call(%{name: name}, _opts), do: ok(message: "Hello #{name}!")
  def call(%{name: nil}, _opts), do: error("name is obrigatory")
end
```

Now our `SayHello` module has the `ok` and `error` macros and a struct for `Output` like `%SayHello.Output{message: "something"}`.

The `ok` and `error` macro can be used to define when our interactor success or fail.

After define, we can call it in many ways:

```elixir
iex> UseCase.call(SayHello, %{name: "Henrique"}) 
iex> {:ok, SayHello.Output{message: "Hello Henrique!", _state: nil}}

iex> SayHello.call(%{name: "Henrique"})
iex> {:ok, SayHello.Output{message: "Hello Henrique!", _state: nil}}

iex> UseCase.call(SayHello, %{name: nil}) 
iex> {:error, SayHello.Error{message: "name is obrigatory!"}}

iex> UseCase.call!(SayHello, %{name: "Henrique"}) 
iex> SayHello.Output{message: "Hello Henrique!", _state: nil}

iex> UseCase.call!(SayHello, %{name: nil}) 
iex> **** SayHello.Error name is obrigatory!
```

### Defining inputs

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
iex> {:ok, SayHello.Output{message: "Hello Henrique!", _state: nil}}

iex> UseCase.call! %SayHello{name: "Henrique"} 
iex> SayHello.Output{message: "Hello Henrique!", _state: nil}
```

### Defining errors

If we want to send extra informations in errors, we can do it as `input` and `output`.

```elixir
defmodule SayHello do
  use UseCase.Interactor,
    output: [:message],
    input: [:name],
    error: [:code] # Add this

  def call(%SayHello{name: name}, _opts), do: ok(message: "Hello #{name}!")
  def call(%SayHello{name: nil}, _opts), do: error("name is obrigatory", code: 500) # And use it
end
```

```elixir
iex> UseCase.call(SayHello, %{name: nil}) 
iex> {:error, SayHello.Error{message: "name is obrigatory!", code: 500}}
```

### Default fields

When not defined, input, output and error defaults to:

```
input: [:_state],
output: [],
error: [:message]
```

Fields `:_state` in `input` and `:message` in `error` are always appended. The `:_state` field is very useful for pipe operations.

### Composing with pipes

Lets define an `LogOperation` interactor:

```elixir
defmodule LogOperation do
  use UseCase.Interactor

  def call(%{message: message}, _opts) do
    # .. log message
    ok()
  end
end
```

We can compose with our `SayHello` simple as that:

```elixir
iex> UseCase.pipe [%SayHello{name: "Henrique"}, LogOperation] 
iex> {:ok, LogOperation.Output{_state: nil}}

iex> UseCase.pipe [%SayHello{name: nil}, LogOperation] 
iex> {:error, SayHello.Error{message: "name is obrigatory!", code: 500}}

iex> UseCase.pipe! [%SayHello{name: "Henrique"}, LogOperation] 
iex> LogOperation.Output{_state: nil}

iex> UseCase.pipe! [%SayHello{name: nil}, LogOperation] 
iex> **** SayHello.Error name is obrigatory!
```

All we need is match outputs and inputs and use one of pipe `UseCase` functions.

### Sending options

All `UseCase` functions last argument is the options keyword list that is sent to interactors:

```Elixir
import UseCase

call(%SayHello{name: "henrique"}, my_option: true)
pipe([%SayHello{name: "Henrique"}, LogOperation], my_option: true)
```


## Contribute

*UseCase* is not only for me, but for the *Elixir* community.

I'm totally open to new ideas. Fork, open issues and feel free to contribute with no bureaucracy. We only need to keep some patterns to maintain an organization:

#### branchs

*your_branch_name*

#### commits

*[your_branch_name] Your commit*
