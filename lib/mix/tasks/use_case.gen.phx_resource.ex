defmodule Mix.Tasks.UseCase.Gen.PhxResource do
  @shortdoc "Generates context, schema, migration and tests for a resource"
  @moduledoc """
    Generates context, schema, migration and tests for a resource.

        mix use_case.gen.phx_resource Posts Post posts title content image likes:int

    The first argument is the context name, the second the resource name, the third the database table name for the resource and the others the resource fields.
  """
  use Mix.Task

  alias UseCase.Mix.Phoenix.Schema

  import UseCase.Mix.Helpers

  @templates_path "use_case.gen.phx_resource"

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.resource ->
          """)
    end

    args = parse_args(args_and_options)

    context_inflected = get_context_inflected(args)
    schema_name = get_schema_name(args)
    table_name = get_table_name(args)
    schema_fields = get_schema_fields(args)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    [_,_|args_without_schema] = args

    create_context(context_inflected, schema)
    create_context_test(context_inflected, schema)

    Mix.Tasks.Phx.Gen.Schema.run([schema_name] ++ args_without_schema)
  end

  defp create_context(context_inflected, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
      "lib/#{Macro.underscore(context_inflected[:base])}/#{context_inflected[:path]}.ex"

    copy_template(
      @templates_path,
      "context.eex",
      path,
      context_inflected: context_inflected,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp create_context_test(context_inflected, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
      "test/#{Macro.underscore(context_inflected[:base])}/#{context_inflected[:path]}_test.exs"

    copy_template(@templates_path, "context_test.eex", path,
      context_inflected: context_inflected,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end
end
