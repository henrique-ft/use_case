defmodule Mix.Tasks.UseCase.Gen.PhxResourceJson do
  @shortdoc "Generates context, schema, migration, controllers, views and tests for a resource"
  @moduledoc """
    Generates context, schema, migration, controllers, views and tests for a resource.

        mix use_case.gen.phx_resource Posts Post posts title content image likes:int

    The first argument is the context name, the second the resource name, the third the database table name for the resource and the others the resource fields.
  """
  use Mix.Task

  alias UseCase.Mix.Phoenix.Schema

  import UseCase.Mix.Helpers

  @template_path "use_case.gen.phx_resource_json"

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_json ->
        """)
    end

    args = parse_args(args_and_options)

    context_inflected = get_context_inflected(args)
    table_name = get_table_name(args)
    schema_name = get_schema_name(args)
    schema_fields = get_schema_fields(args)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    create_controller(context_inflected, schema)
    create_controller_test(context_inflected, schema)

    create_fallback_controller(context_inflected, schema)

    create_view(context_inflected, schema)
    create_changeset_view(context_inflected, schema)

    Mix.Tasks.UseCase.Gen.PhxResource.run(false, args_and_options)
  end

  defp create_controller(context_inflected, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    updated_module =
      schema.module
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    require IEx; IEx.pry
    path =
      "lib/#{context_inflected[:web_path]}/controllers/#{context_inflected[:path]}_controller.ex"

    copy_template(@template_path, "controller.eex", path,
      context_inflected: context_inflected,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp create_controller_test(context_inflected, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
      "test/#{context_inflected[:web_path]}/controllers/#{context_inflected[:path]}_controller_test.ex"

    copy_template(@template_path, "controller_test.eex", path,
      context_inflected: context_inflected,
      schema: Map.merge(schema, %{alias: updated_alias})
    )
  end

  defp create_fallback_controller(context_inflected, schema) do
    copy_template(@template_path, "fallback_controller.eex", "lib/#{context_inflected[:web_path]}/controllers/fallback_controller.ex",
      context_inflected: context_inflected,
      schema: schema
    )
  end

  defp create_view(context_inflected, schema) do
    updated_alias =
      schema.alias
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    path =
        "lib/#{context_inflected[:web_path]}/views/#{context_inflected[:path]}_view.ex"

    copy_template(@template_path, "view.eex", path,
      context_inflected: context_inflected,
      schema: Map.merge(schema, %{alias: updated_alias})
    )
  end

  defp create_changeset_view(context_inflected, schema) do
    copy_template(@template_path, "changeset_view.eex", "lib/#{context_inflected[:web_path]}/views/changeset_view.ex",
      context_inflected: context_inflected,
      schema: schema
    )
  end
end
