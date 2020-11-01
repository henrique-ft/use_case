defmodule Mix.Tasks.UseCase.Gen.PhxResource do
  @shortdoc "Generates repo, schema, migration and tests for a resource"
  @moduledoc """
    Generates repo, schema, migration and tests for a resource.

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

        use_case.gen.resource ->

        """)
    end

    {options, args, []} = OptionParser.parse(args_and_options, strict: [context: :string])

    option_context = get_option_context(Keyword.get(options, :context, nil))
    context = get_context(args)
    table_name = get_table_name(args)
    schema_name = get_schema_name(args, option_context)
    schema_fields = get_schema_fields(args)

    schema = Schema.new(schema_name, table_name, schema_fields, [])

    [_|args_without_schema] = args

    create_repo(context, schema, option_context)
    create_repo_test(context, schema, option_context)

    Mix.Tasks.Phx.Gen.Schema.run([schema_name] ++ args_without_schema)
  end

  defp create_repo(context, schema, option_context) do
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
        "lib/#{Macro.underscore(context[:base])}/#{option_context[:path]}/repo/#{context[:path]}.ex"
      else
        "lib/#{Macro.underscore(context[:base])}/repo/#{context[:path]}.ex"
      end

    copy_template(
      "repo.eex",
      path,
      context: context,
      option_context: option_context,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp create_repo_test(context, schema, option_context) do
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
        "test/#{Macro.underscore(context[:base])}/#{option_context[:path]}/repo/#{context[:path]}_test.ex"
      else
        "test/#{Macro.underscore(context[:base])}/repo/#{context[:path]}_test.exs"
      end

    copy_template("repo_test.eex", path,
      context: context,
      option_context: option_context,
      schema: Map.merge(schema, %{alias: updated_alias, module: updated_module})
    )
  end

  defp copy_template(name, final_path, opts) do
    Path.join(:code.priv_dir(:use_case), "templates/use_case.gen.phx_resource/#{name}")
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
end
