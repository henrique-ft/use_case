defmodule Mix.Tasks.UseCase.Gen.Prt do
  use Mix.Task

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_temple ->

        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResourceTemple.run(false, args)
  end
end
