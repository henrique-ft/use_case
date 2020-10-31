defmodule Mix.Tasks.UseCase.Gen.PhxResourceTemple do
  use Mix.Task

  alias UcScaffold.Mix.Phoenix.Schema

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_temple ->

        """)
    end

    context = get_context(args)
    table_name = get_table_name(args)
    schema_name = get_schema_name(args)
    schema_fields = get_schema_fields(args)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    create_controller(context, schema)
    create_controller_test(context, schema)

    create_view(context, schema)

    create_edit_html(context, schema)
    create_form_html(context, schema)
    create_index_html(context, schema)
    create_new_html(context, schema)
    create_show_html(context, schema)

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

  defp create_view(context, schema) do
    copy_template("view.eex", "lib/#{context[:web_path]}/views/#{context[:path]}_view.ex",
      context: context,
      schema: schema
    )
  end

  defp create_edit_html(context, schema) do
    copy_template("temple/edit.html.eex", "lib/#{context[:web_path]}/templates/#{context[:path]}/edit.html.exs",
      schema: schema
    )
  end

  defp create_form_html(context, schema) do
    copy_template("temple/form.html.eex", "lib/#{context[:web_path]}/templates/#{context[:path]}/form.html.exs",
      schema: schema,
      inputs: inputs(schema)
    )
  end

  defp create_index_html(context, schema) do
    copy_template("temple/index.html.eex", "lib/#{context[:web_path]}/templates/#{context[:path]}/index.html.exs",
      schema: schema
    )
  end

  defp create_new_html(context, schema) do
    copy_template("temple/new.html.eex", "lib/#{context[:web_path]}/templates/#{context[:path]}/new.html.exs",
      schema: schema
    )
  end

  defp create_show_html(context, schema) do
    copy_template("temple/show.html.eex", "lib/#{context[:web_path]}/templates/#{context[:path]}/show.html.exs",
      schema: schema
    )
  end

  defp copy_template(name, final_path, opts) do
    Path.join(:code.priv_dir(:uc_scaffold), "templates/use_case.gen.phx_resource_html/#{name}")
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

  defp inputs(%Schema{} = schema) do
    Enum.map(schema.attrs, fn
      {_, {:references, _}} ->
        {nil, nil, nil}
      {key, :integer} ->
        {label(key), ~s(number_input f, #{inspect(key)}), error(key)}
      {key, :float} ->
        {label(key), ~s(number_input f, #{inspect(key)}, step: "any"), error(key)}
      {key, :decimal} ->
        {label(key), ~s(number_input f, #{inspect(key)}, step: "any"), error(key)}
      {key, :boolean} ->
        {label(key), ~s(checkbox f, #{inspect(key)}), error(key)}
      {key, :text} ->
        {label(key), ~s(textarea f, #{inspect(key)}), error(key)}
      {key, :date} ->
        {label(key), ~s(date_select f, #{inspect(key)}), error(key)}
      {key, :time} ->
        {label(key), ~s(time_select f, #{inspect(key)}), error(key)}
      {key, :utc_datetime} ->
        {label(key), ~s(datetime_select f, #{inspect(key)}), error(key)}
      {key, :naive_datetime} ->
        {label(key), ~s(datetime_select f, #{inspect(key)}), error(key)}
      {key, {:array, :integer}} ->
        {label(key), ~s(multiple_select f, #{inspect(key)}, ["1": 1, "2": 2]), error(key)}
      {key, {:array, _}} ->
        {label(key), ~s(multiple_select f, #{inspect(key)}, ["Option 1": "option1", "Option 2": "option2"]), error(key)}
      {key, _}  ->
        {label(key), ~s(text_input f, #{inspect(key)}), error(key)}
    end)
  end

  defp label(key) do
    ~s(label f, #{inspect(key)})
  end

  defp error(field) do
    ~s(error_tag f, #{inspect(field)})
  end
end
