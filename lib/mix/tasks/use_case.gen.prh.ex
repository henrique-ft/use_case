defmodule Mix.Tasks.UseCase.Gen.Prh do
  use Mix.Task

  def run(io_puts \\ true, args) do
    if io_puts do
      IO.puts("""

        use_case.gen.phx_resource_html ->

        """)
    end

    Mix.Tasks.UseCase.Gen.PhxResourceHtml.run(false, args)
  end
end
