defmodule Protohack.Handler.Prime do
  use ThousandIsland.Handler
  require Logger

  # Probably a very bad idea to only process everything when the timeout
  # occurs.
  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    case ThousandIsland.Socket.recv(socket, 0, 100) do
      {:ok, bytes} -> handle_data(data <> bytes, socket, state)
      {:error, :timeout} -> real_handle_data(data, socket, state)
    end
  end

  def real_handle_data(data, socket, state) do
    state =
      case state do
        [] -> 0
        _ -> state + 1
      end

    data = String.trim(data)
    Logger.info("#{state} <<- #{data}")

    String.split(data, "\n")
    |> process_data(socket, state)
  end

  defp process_data([], _socket, state) do
    {:continue, state}
  end

  defp process_data([request | rest], socket, state) do
    {status, response} = process_request(request, state)
    response = response |> Jason.encode!()
    Logger.info("#{state} -> #{response}")
    ThousandIsland.Socket.send(socket, response <> "\n")

    case status do
      :error -> {:close, state + 1}
      :ok -> process_data(rest, socket, state + 1)
    end
  end

  defp process_request(request, state) do
    Logger.info("#{state} <- #{request}")

    case request |> Jason.decode() do
      {:error, _} -> handle_request(:error)
      {:ok, request} -> handle_request(request)
    end
  end

  defp handle_request(%{"method" => "isPrime", "number" => n}) when is_number(n) do
    prime =
      case is_integer(n) do
        false -> false
        true -> Prime.test(n)
      end

    {:ok, %{method: "isPrime", prime: prime}}
  end

  defp handle_request(_) do
    {:error, malformed_response()}
  end

  defp malformed_response do
    %{error: "Malformed request"}
  end
end
