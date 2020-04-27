defmodule UseCase do
  def call(interactor, input, opts) when is_atom(interactor), do: interactor.call(input, opts)

  def call(interactor, input) when is_atom(interactor), do: interactor.call(input, [])

  def call(%interactor{} = input, opts), do: interactor.call(input, opts)

  def call(%interactor{} = input), do: interactor.call(input, [])

  def call(interactor) when is_atom(interactor), do: interactor.call(%{}, [])

  def call!(interactor, input, opts) when is_atom(interactor),
    do: interactor.call(input, opts) |> bang!

  def call!(interactor, input) when is_atom(interactor),
    do: interactor.call(input, []) |> bang!

  def call!(%interactor{} = input, opts),
    do: interactor.call(input, opts) |> bang!

  def call!(%interactor{} = input),
    do: interactor.call(input, []) |> bang!

  defp bang!(output) do
    case output do
      {:ok, result} -> result
      {:error, error} -> raise(error)
      otherthing -> otherthing
    end
  end
end
