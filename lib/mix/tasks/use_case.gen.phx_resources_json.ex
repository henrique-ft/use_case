defmodule Mix.Tasks.UseCase.Gen.PhxResourceJson do
  use Mix.Task

  alias UcScaffold.Mix.Phoenix.Schema

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_json ->

        """)
    end

    context = get_context(args)
    table_name = get_table_name(args)
    schema_name = get_schema_name(args)
    schema_fields = get_schema_fields(args)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    create_controller(context, schema)
    create_controller_test(context, schema) # Testar implementação

    create_fallback_controller(context, schema)

    create_view(context, schema)
    create_changeset_view(context, schema)

    Mix.Tasks.UseCase.Gen.PhxResource.run(false, args)
  end

  defp create_controller(context, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    copy_template("controller.eex", "lib/#{context[:web_path]}/controllers/#{context[:path]}_controller.ex",
      context: context,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp create_controller_test(context, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    copy_template("controller_test.eex", "test/#{context[:web_path]}/controllers/#{context[:path]}_controller_test.exs",
      context: context,
      schema: Map.merge(schema, %{alias: updated_alias})
    )
  end

  defp create_fallback_controller(context, schema) do
    copy_template("fallback_controller.eex", "lib/#{context[:web_path]}/controllers/fallback_controller.ex",
      context: context,
      schema: schema
    )
  end

  defp create_view(context, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    copy_template("view.eex", "lib/#{context[:web_path]}/views/#{context[:path]}_view.ex",
      context: context,
      schema: Map.merge(schema, %{alias: updated_alias})
    )
  end

  defp create_changeset_view(context, schema) do
    copy_template("changeset_view.eex", "lib/#{context[:web_path]}/views/changeset_view.ex",
      context: context,
      schema: schema
    )
  end

  defp copy_template(name, final_path, opts) do
    Path.join(:code.priv_dir(:uc_scaffold), "templates/use_case.gen.phx_resource_json/#{name}")
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
