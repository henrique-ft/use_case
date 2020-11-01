defmodule Mix.Tasks.UseCase.Gen.Prh do
  @shortdoc "An alias to use_case.gen.phx_resource_html"

  use Mix.Task

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.prh ->
        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResourceHtml.run(false, args)
  end
end
