defmodule UseCase.Mix.Phoenix.Inflector do
  @moduledoc false

  @doc """
  Inflects path, scope, alias and more from the given name.

  ## Examples

  ```
  [alias: "User",
   human: "User",
   base: "Phoenix",
   web_module: "PhoenixWeb",
   module: "Phoenix.User",
   scoped: "User",
   singular: "user",
   path: "user"]

  [alias: "User",
   human: "User",
   base: "Phoenix",
   web_module: "PhoenixWeb",
   module: "Phoenix.Admin.User",
   scoped: "Admin.User",
   singular: "user",
   path: "admin/user"]

  [alias: "SuperUser",
   human: "Super user",
   base: "Phoenix",
   web_module: "PhoenixWeb",
   module: "Phoenix.Admin.SuperUser",
   scoped: "Admin.SuperUser",
   singular: "super_user",
   path: "admin/super_user"]
   ```

  """
  def call(singular) do
    base = get_base()
    web_module = base |> web_module() |> inspect()
    web_path = base |> web_path()
    scoped = camelize(singular)
    path = underscore(scoped)
    singular = String.split(path, "/") |> List.last()
    module = Module.concat(base, scoped) |> inspect
    test_module = "#{module}Test"
    alias = String.split(module, ".") |> List.last()
    human = humanize(singular)

    [
      alias: alias,
      human: human,
      base: base,
      web_module: web_module,
      web_path: web_path,
      test_module: test_module,
      module: module,
      scoped: scoped,
      singular: singular,
      path: path
    ]
  end

  defp web_path(base) do
    "#{Macro.underscore(base)}_web"
  end

  defp web_module(base) do
    if base |> to_string() |> String.ends_with?("Web") do
      Module.concat([base])
    else
      Module.concat(["#{base}Web"])
    end
  end

  defp get_base do
    app_base(otp_app())
  end

  defp app_base(app) do
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string() |> camelize()
      mod -> mod |> inspect()
    end
  end

  defp otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  defp camelize(value), do: Macro.camelize(value)

  defp underscore(value), do: Macro.underscore(value)

  defp humanize(atom) when is_atom(atom),
    do: humanize(Atom.to_string(atom))

  defp humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> String.capitalize()
  end
end
