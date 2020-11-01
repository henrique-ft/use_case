defmodule Mix.Tasks.UseCase.Gen.PhxResourceJson do
  @shortdoc "Generates repo, schema, migration, controllers, views and tests for a resource"
  @moduledoc """
    Generates repo, schema, migration, controllers, views and tests for a resource.

        mix use_case.gen.phx_resource Post posts title content image likes:int

    or

        mix use_case.gen.phx_resource Post posts title content image likes:int --context MyBoundedContext

    The first argument is the resource name, the second the database table name for the resource and the others the resource fields. We can set the --context flag to create the resource in context folders and namespaces
  """
  use Mix.Task

  alias UcScaffold.Mix.Phoenix.Schema

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_json ->
        """)
    end

    {options, args, []} = OptionParser.parse(args_and_options, strict: [context: :string])

    option_context = get_option_context(Keyword.get(options, :context, nil))
    context = get_context(args)
    table_name = get_table_name(args)
    schema_name = get_schema_name(args, option_context)
    schema_fields = get_schema_fields(args)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    create_controller(context, schema, option_context)
    create_controller_test(context, schema, option_context) # Testar implementação

    create_fallback_controller(context, schema)

    create_view(context, schema, option_context)
    create_changeset_view(context, schema)

    Mix.Tasks.UseCase.Gen.PhxResource.run(false, args_and_options)
  end

  defp create_controller(context, schema, option_context) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/controllers/#{option_context[:path]}/#{context[:path]}_controller.ex"
      else
        "lib/#{context[:web_path]}/controllers/#{context[:path]}_controller.ex"
      end

    copy_template("controller.eex", path,
      context: context,
      option_context: option_context,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp create_controller_test(context, schema, option_context) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
      if Keyword.get(option_context, :path, false) do
        "test/#{context[:web_path]}/controllers/#{option_context[:path]}/#{context[:path]}_controller_test.exs"
      else
        "test/#{context[:web_path]}/controllers/#{context[:path]}_controller_test.exs"
      end

    copy_template("controller_test.eex", path,
      context: context,
      option_context: option_context,
      schema: Map.merge(schema, %{alias: updated_alias})
    )
  end

  defp create_fallback_controller(context, schema) do
    copy_template("fallback_controller.eex", "lib/#{context[:web_path]}/controllers/fallback_controller.ex",
      context: context,
      schema: schema
    )
  end

  defp create_view(context, schema, option_context) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/views/#{option_context[:path]}/#{context[:path]}_view.ex"
      else
        "lib/#{context[:web_path]}/views/#{context[:path]}_view.ex"
      end

    copy_template("view.eex", path,
      context: context,
      option_context: option_context,
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
    Path.join(:code.priv_dir(:use_case), "templates/use_case.gen.phx_resource_json/#{name}")
    |> Mix.Generator.copy_template(final_path, opts)
  end

  defp get_table_name([_,table_name|_]) do
    table_name
  end

  defp get_table_name(_) do
    raise "Table name is obrigatory"
  end

  defp get_schema_name([schema|_], []) do
    "Schemas.#{schema}"
  end

  defp get_schema_name([schema|_], option_context) do
    option_context[:scoped] <> ".Schemas.#{schema}"
  end

  defp get_schema_fields([_,_|schema_fields]) do
    schema_fields
  end

  defp get_option_context(nil), do: []

  defp get_option_context(name) do
    call_phoenix_inflector(name)
  end

  defp call_phoenix_inflector(name) do
    UcScaffold.Mix.Phoenix.Inflector.call(name)
  end

  defp get_context([schema_name|_]) do
    call_phoenix_inflector(schema_name)
  end

  defp get_context(_) do
    raise "Schema name is obrigatory"
  end
end
