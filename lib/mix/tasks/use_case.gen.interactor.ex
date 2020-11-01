defmodule Mix.Tasks.UseCase.Gen.Interactor do
  @shortdoc "Generates a interactor and its tests"
  @moduledoc """
    Generates a interactor and its tests.

        mix use_case.gen.interactor DoSomething.Cool

    or

        mix use_case.gen.interactor DoSomething.Cool --context MyBoundedContext

    The first argument is the interactor name. We can set the --context flag to create an interactor in a context folder and namespace
  """


  use Mix.Task

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.interactor ->
        """)
    end

    {options, args, []} = OptionParser.parse(args_and_options, strict: [context: :string])

    option_context = get_option_context(Keyword.get(options, :context, nil))
    context = get_context(args)

    create_interactor(context, option_context)
    create_interactor_test(context, option_context)
  end

  defp create_interactor(context, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{Macro.underscore(context[:base])}/#{option_context[:path]}/interactors/#{context[:path]}.ex"
      else
        "lib/#{Macro.underscore(context[:base])}/interactors/#{context[:path]}.ex"
      end

    copy_template(
      "interactor.eex",
      path,
      option_context: option_context,
      context: context
    )
  end

  defp create_interactor_test(context, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "test/#{Macro.underscore(context[:base])}/#{option_context[:path]}/interactors/#{context[:path]}_test.ex"
      else
        "test/#{Macro.underscore(context[:base])}/interactors/#{context[:path]}_test.ex"
      end

    copy_template(
      "interactor_test.eex",
      path,
      option_context: option_context,
      context: context
    )
  end

  defp copy_template(name, final_path, opts) do
    Path.join(:code.priv_dir(:use_case), "templates/use_case.gen.interactor/#{name}")
    |> Mix.Generator.copy_template(final_path, opts)
  end

  defp get_context([schema_name|_]) do
    call_phoenix_inflector(schema_name)
  end

  defp get_context(_) do
    raise "Schema name is obrigatory"
  end

  defp get_option_context(nil), do: []

  defp get_option_context(name) do
    call_phoenix_inflector(name)
  end

  defp call_phoenix_inflector(name) do
    UcScaffold.Mix.Phoenix.Inflector.call(name)
  end
end
