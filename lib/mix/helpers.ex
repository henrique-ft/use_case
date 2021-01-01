defmodule UseCase.Mix.Helpers do
  @moduledoc false

  use Mix.Task

  def parse_args(args_and_options) do
    {_, args, _} = OptionParser.parse(args_and_options, strict: [])

    args
  end

  def copy_template(path, name, final_path, opts) do
    Path.join(:code.priv_dir(:use_case), "templates/#{path}/#{name}")
    |> Mix.Generator.copy_template(final_path, opts)
  end

  def get_table_name([_,_,table_name|_]) do
    table_name
  end

  def get_table_name(_) do
    raise "Table name is obrigatory"
  end

  def get_schema_name([_,schema|_]) do
    "Schemas.#{schema}"
  end

  def get_schema_name(_) do
    raise "Schema name is obrigatory"
  end

  def get_schema_fields([_,_,_|schema_fields]) do
    schema_fields
  end

  def get_context_inflected([context_name|_]) do
    call_phoenix_inflector(context_name)
  end

  def get_context_inflected(_) do
    raise "Context name is obrigatory"
  end

  def call_phoenix_inflector(name) do
    UseCase.Mix.Phoenix.Inflector.call(name)
  end
end
