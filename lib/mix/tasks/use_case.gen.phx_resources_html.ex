defmodule Mix.Tasks.UseCase.Gen.PhxResourceHtml do
  @shortdoc "Generates context, schema, migration, controllers, html templates, views and tests for a resource"
  @moduledoc """
    Generates context, schema, migration, controllers, html templates, views and tests for a resource.

        mix use_case.gen.phx_resource Posts Post posts title content image likes:int

    The first argument is the context name, the second the resource name, the third the database table name for the resource and the others the resource fields.
  """
  use Mix.Task

  alias UseCase.Mix.Phoenix.Schema

  import UseCase.Mix.Helpers

  @template_path "use_case.gen.phx_resource_html"

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_html ->
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

    create_view(context_inflected, schema)

    create_edit_html(context_inflected, schema)
    create_form_html(context_inflected, schema)
    create_index_html(context_inflected, schema)
    create_new_html(context_inflected, schema)
    create_show_html(context_inflected, schema)

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

  defp create_view(context_inflected, schema) do
    path =
      "lib/#{context_inflected[:web_path]}/views/#{context_inflected[:path]}_view.ex"

    copy_template(@template_path, "view.eex", path,
      context_inflected: context_inflected,
      schema: schema
    )
  end

  defp create_edit_html(context_inflected, schema) do
    path =
      "lib/#{context_inflected[:web_path]}/templates/#{context_inflected[:path]}/edit.html.eex"

    copy_template(@template_path, "edit.html.eex", path,
      schema: schema
    )
  end

  defp create_form_html(context_inflected, schema) do
    path =
      "lib/#{context_inflected[:web_path]}/templates/#{context_inflected[:path]}/form.html.eex"

    copy_template(@template_path, "form.html.eex", path,
      schema: schema,
      inputs: inputs(schema)
    )
  end

  defp create_index_html(context_inflected, schema) do
    path =
      "lib/#{context_inflected[:web_path]}/templates/#{context_inflected[:path]}/index.html.eex"

    copy_template(@template_path, "index.html.eex", path,
      schema: schema
    )
  end

  defp create_new_html(context_inflected, schema) do
    path =
      "lib/#{context_inflected[:web_path]}/templates/#{context_inflected[:path]}/new.html.eex"

    copy_template(@template_path, "new.html.eex", path,
      schema: schema
    )
  end

  defp create_show_html(context_inflected, schema) do
    path =
      "lib/#{context_inflected[:web_path]}/templates/#{context_inflected[:path]}/show.html.eex"

    copy_template(@template_path, "show.html.eex", path,
      schema: schema
    )
  end

  defp inputs(%Schema{} = schema) do
    Enum.map(schema.attrs, fn
      {_, {:references, _}} ->
        {nil, nil, nil}
      {key, :integer} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)} %>), error(key)}
      {key, :float} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, step: "any" %>), error(key)}
      {key, :decimal} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, step: "any" %>), error(key)}
      {key, :boolean} ->
        {label(key), ~s(<%= checkbox f, #{inspect(key)} %>), error(key)}
      {key, :text} ->
        {label(key), ~s(<%= textarea f, #{inspect(key)} %>), error(key)}
      {key, :date} ->
        {label(key), ~s(<%= date_select f, #{inspect(key)} %>), error(key)}
      {key, :time} ->
        {label(key), ~s(<%= time_select f, #{inspect(key)} %>), error(key)}
      {key, :utc_datetime} ->
        {label(key), ~s(<%= datetime_select f, #{inspect(key)} %>), error(key)}
      {key, :naive_datetime} ->
        {label(key), ~s(<%= datetime_select f, #{inspect(key)} %>), error(key)}
      {key, {:array, :integer}} ->
        {label(key), ~s(<%= multiple_select f, #{inspect(key)}, ["1": 1, "2": 2] %>), error(key)}
      {key, {:array, _}} ->
        {label(key), ~s(<%= multiple_select f, #{inspect(key)}, ["Option 1": "option1", "Option 2": "option2"] %>), error(key)}
      {key, _}  ->
        {label(key), ~s(<%= text_input f, #{inspect(key)} %>), error(key)}
    end)
  end

  defp label(key) do
    ~s(<%= label f, #{inspect(key)} %>)
  end

  defp error(field) do
    ~s(<%= error_tag f, #{inspect(field)} %>)
  end
end
