defmodule UseCase do
  def pipe(input, [interactor | _] = interactors, opts) when is_atom(interactor),
    do: pipe_loop(interactors, input, opts)

  def pipe(input, [interactor | _] = interactors) when is_atom(interactor),
    do: pipe_loop(interactors, input, [])

  def pipe(interactors, opts), do: pipe_loop(interactors, opts)

  def pipe(interactors), do: pipe_loop(interactors, [])

  defp pipe_loop([], input, _opts), do: {:ok, input}

  defp pipe_loop([interactor | interactors], input, opts) do
    with {:ok, output} <- call(interactor, input, opts), do: pipe_loop(interactors, output, opts)
  end

  defp pipe_loop([interactor | interactors], opts) do
    with {:ok, output} <- call(interactor, opts), do: pipe_loop(interactors, output, opts)
  end

  def pipe!(input, [interactor | _] = interactors, opts) when is_atom(interactor),
    do: pipe_loop!(interactors, input, opts)

  def pipe!(input, [interactor | _] = interactors) when is_atom(interactor),
    do: pipe_loop!(interactors, input, [])

  def pipe!(interactors, opts), do: pipe_loop!(interactors, opts)

  def pipe!(interactors), do: pipe_loop!(interactors, [])

  defp pipe_loop!([], output, _opts), do: output

  defp pipe_loop!([interactor | interactors], input, opts),
    do: pipe_loop!(interactors, call!(interactor, input, opts), opts)

  defp pipe_loop!([interactor | interactors], opts),
    do: pipe_loop!(interactors, call!(interactor, opts), opts)

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
