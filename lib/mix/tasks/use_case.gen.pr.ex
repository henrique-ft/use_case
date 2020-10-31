defmodule Mix.Tasks.UseCase.Gen.Pr do
  use Mix.Task

  alias UcScaffold.Mix.Phoenix.Schema

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource ->

        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResource.run(false, args)
  end
end
