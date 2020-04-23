defmodule UseCase do
  defmacro __using__(opts \\ []) do
    quote do
      defstruct unquote(Keyword.get(opts, :input, []))
      defmodule Output, do: defstruct(unquote(Keyword.get(opts, :output, [])))
      defmodule Error, do: defexception(unquote(Keyword.get(opts, :error, []) ++ [:message]))

      def ok, do: {:ok, %__MODULE__.Output{}}
      def ok(nil), do: {:ok, %__MODULE__.Output{}}
      def ok([]), do: {:ok, %__MODULE__.Output{}}
      def ok(attr_values), do: {:ok, struct(__MODULE__.Output, attr_values)}
      def error, do: {:error, %__MODULE__.Error{}}
      def error(nil), do: {:error, %__MODULE__.Error{}}
      def error(nil, []), do: {:error, struct(__MODULE__.Error, [])}
      def error(nil, attr_values), do: {:error, struct(__MODULE__.Error, attr_values)}
      def error(message, []), do: {:error, struct(__MODULE__.Error, message: message)}

      def error(message, attr_values),
        do: {:error, struct(__MODULE__.Error, attr_values ++ [message: message])}

      def error(message), do: {:error, struct(__MODULE__.Error, message: message)}
    end
  end

  def call(use_case, input, opts) when is_atom(use_case), do: use_case.call(input, opts)

  def call(use_case, input) when is_atom(use_case), do: use_case.call(input, [])

  def call(%use_case{} = input, opts), do: use_case.call(input, opts)

  def call(%use_case{} = input), do: use_case.call(input, [])

  def call!(use_case, input, opts) when is_atom(use_case),
    do: use_case.call(input, opts) |> bang!

  def call!(use_case, input) when is_atom(use_case),
    do: use_case.call(input, []) |> bang!

  def call!(%use_case{} = input, opts),
    do: use_case.call(input, opts) |> bang!

  def call!(%use_case{} = input),
    do: use_case.call(input, []) |> bang!

  defp bang!(output) do
    case output do
      {:ok, result} -> result
      {:error, error} -> raise(error)
      otherthing -> otherthing
    end
  end
end
