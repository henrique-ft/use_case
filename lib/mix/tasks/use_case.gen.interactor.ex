defmodule Mix.Tasks.UseCase.Gen.Interactor do
  @shortdoc "Generates a interactor and its tests"
  @moduledoc """
    Generates a interactor and its tests.

        mix use_case.gen.interactor DoSomething.Cool

    The first argument is the interactor name.
  """

  use Mix.Task

  import UseCase.Mix.Helpers

  @template_path "use_case.gen.interactor"

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.interactor ->
        """)
    end

    args = parse_args(args_and_options)

    context_inflected = get_context_inflected(args)

    create_interactor(context_inflected)
    create_interactor_test(context_inflected)
  end

  defp create_interactor(context_inflected) do
    path =
      "lib/#{Macro.underscore(context_inflected[:base])}/#{context_inflected[:path]}.ex"

    copy_template(
      @template_path,
      "interactor.eex",
      path,
      context_inflected: context_inflected
    )
  end

  defp create_interactor_test(context_inflected) do
    path =
      "test/#{Macro.underscore(context_inflected[:base])}/#{context_inflected[:path]}_test.ex"

    copy_template(
      @template_path,
      "interactor_test.eex",
      path,
      context_inflected: context_inflected
    )
  end
end
