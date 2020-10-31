defmodule Mix.Tasks.UseCase.Gen.PhxResource do
  use Mix.Task

  alias UcScaffold.Mix.Phoenix.Schema

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.resource ->

        """)
    end

    context = get_context(args)
    table_name = get_table_name(args)
    schema_name = get_schema_name(args)
    schema_fields = get_schema_fields(args)

    IO.inspect(context)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    IO.inspect(schema)

    [_|args_without_schema] = args

    create_repo(context, schema)
    create_repo_test(context, schema)

    Mix.Tasks.Phx.Gen.Schema.run([schema_name] ++ args_without_schema)
  end

  defp create_repo(context, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    copy_template("repo.eex", "lib/#{Macro.underscore(context[:base])}/repo/#{context[:path]}.ex",
      context: context,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp create_repo_test(context, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    copy_template("repo_test.eex", "test/#{Macro.underscore(context[:base])}/repo/#{context[:path]}_test.exs",
      context: context,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp copy_template(name, final_path, opts) do
    Path.join(:code.priv_dir(:uc_scaffold), "templates/use_case.gen.phx_resource/#{name}")
    |> Mix.Generator.copy_template(final_path, opts)
  end

  defp get_table_name([_,table_name|_]) do
    table_name
  end

  defp get_schema_name([schema|_]) do
    "Schemas.#{schema}"
  end

  defp get_schema_fields([_,_|schema_fields]) do
    schema_fields
  end

  defp get_context([schema_name|_]) do
    UcScaffold.Mix.Phoenix.Inflector.call(schema_name)
  end

  defp get_context(_) do
    raise "Schema name is obrigatory"
  end
end
