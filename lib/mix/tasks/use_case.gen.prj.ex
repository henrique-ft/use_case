defmodule Mix.Tasks.UseCase.Gen.Prj do
  @shortdoc "An alias to use_case.gen.phx_resource_json"

  use Mix.Task

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.prj ->
        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResourceJson.run(false, args)
  end
end
