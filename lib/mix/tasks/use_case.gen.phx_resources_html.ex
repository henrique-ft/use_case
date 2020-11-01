defmodule Mix.Tasks.UseCase.Gen.PhxResourceHtml do
  @shortdoc "Generates repo, schema, migration, controllers, html templates, views and tests for a resource"

  use Mix.Task

  alias UcScaffold.Mix.Phoenix.Schema

  def run(io_puts \\ true, args_and_options) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_html ->

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
    create_controller_test(context, schema, option_context)

    create_view(context, schema, option_context)

    create_edit_html(context, schema, option_context)
    create_form_html(context, schema, option_context)
    create_index_html(context, schema, option_context)
    create_new_html(context, schema, option_context)
    create_show_html(context, schema, option_context)

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
        "test/#{context[:web_path]}/controllers/#{option_context[:path]}/#{context[:path]}_controller_test.ex"
      else
        "test/#{context[:web_path]}/controllers/#{context[:path]}_controller_test.ex"
      end

    copy_template("controller_test.eex", path,
      context: context,
      option_context: option_context,
      schema: Map.merge(schema, %{alias: updated_alias})
    )
  end

  defp create_view(context, schema, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/views/#{option_context[:path]}/#{context[:path]}_view.ex"
      else
        "lib/#{context[:web_path]}/views/#{context[:path]}_view.ex"
      end

    copy_template("view.eex", path,
      context: context,
      option_context: option_context,
      schema: schema
    )
  end

  defp create_edit_html(context, schema, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/templates/#{option_context[:path]}/#{context[:path]}/edit.html.eex"
      else
        "lib/#{context[:web_path]}/templates/#{context[:path]}/edit.html.eex"
      end

    copy_template("edit.html.eex", path,
      schema: schema
    )
  end

  defp create_form_html(context, schema, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/templates/#{option_context[:path]}/#{context[:path]}/form.html.eex"
      else
        "lib/#{context[:web_path]}/templates/#{context[:path]}/form.html.eex"
      end

    copy_template("form.html.eex", path,
      schema: schema,
      inputs: inputs(schema)
    )
  end

  defp create_index_html(context, schema, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/templates/#{option_context[:path]}/#{context[:path]}/index.html.eex"
      else
        "lib/#{context[:web_path]}/templates/#{context[:path]}/index.html.eex"
      end

    copy_template("index.html.eex", path,
      schema: schema
    )
  end

  defp create_new_html(context, schema, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/templates/#{option_context[:path]}/#{context[:path]}/new.html.eex"
      else
        "lib/#{context[:web_path]}/templates/#{context[:path]}/new.html.eex"
      end

    copy_template("new.html.eex", path,
      schema: schema
    )
  end

  defp create_show_html(context, schema, option_context) do
    path =
      if Keyword.get(option_context, :path, false) do
        "lib/#{context[:web_path]}/templates/#{option_context[:path]}/#{context[:path]}/show.html.eex"
      else
        "lib/#{context[:web_path]}/templates/#{context[:path]}/show.html.eex"
      end

    copy_template("show.html.eex", path,
      schema: schema
    )
  end

  defp copy_template(name, final_path, opts) do
    Path.join(:code.priv_dir(:use_case), "templates/use_case.gen.phx_resource_html/#{name}")
    |> Mix.Generator.copy_template(final_path, opts)
  end

  defp get_table_name([_,table_name|_]) do
    table_name
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
