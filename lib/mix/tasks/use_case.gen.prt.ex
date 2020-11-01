defmodule Mix.Tasks.UseCase.Gen.Prt do
  @shortdoc "An alias to use_case.gen.phx_resource_temple"

  use Mix.Task

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.prt ->
        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResourceTemple.run(false, args)
  end
end
