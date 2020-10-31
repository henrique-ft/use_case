defmodule Mix.Tasks.UseCase.Gen.Prj do
  use Mix.Task

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_json ->

        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResourceJson.run(false, args)
  end
end
