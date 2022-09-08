defmodule Protohack.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      Enum.map(handlers(), fn {id, port, handler} ->
        Supervisor.child_spec({ThousandIsland, port: port, handler_module: handler}, id: id)
      end)

    opts = [strategy: :one_for_one, name: Protohack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp handlers do
    [
      {:echo, 5555, Protohack.Handler.Echo},
      {:prime, 5556, Protohack.Handler.Prime},
      {:queries, 5557, Protohack.Handler.Queries}
    ]
  end
end
