defmodule Protohack.Handler.Queries do
  use ThousandIsland.Handler
  require Logger

  @impl ThousandIsland.Handler
  def handle_connection(_socket, _state) do
    {:continue, {[], <<>>}}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, {store, buffer}) do
    buffer = buffer <> data

    {store, buffer} =
      if byte_size(buffer) >= 9 do
        process_data(buffer, socket, store)
      else
        {store, buffer}
      end

    {:continue, {store, buffer}, 1000}
  end

  def process_data(
        <<"I", time::signed-size(32), price::signed-size(32), rest::binary>>,
        socket,
        store
      ) do
    Logger.info("#{socket.connection_id}  INSERT time=#{time} price=#{price}")

    process_data(rest, socket, [{time, price} | store])
  end

  def process_data(
        <<"Q", from::signed-size(32), to::signed-size(32), rest::binary>>,
        socket,
        store
      ) do
    Logger.info("#{socket.connection_id}  QUERY from=#{from} to=#{to}")

    values =
      store
      |> Enum.filter(fn {time, _price} -> time >= from && time <= to end)
      |> Enum.map(fn {_time, price} -> price end)

    mean =
      if Enum.count(values) == 0 do
        0
      else
        trunc(Enum.sum(values) / Enum.count(values))
      end

    Logger.info("#{socket.connection_id}  REPLY mean=#{mean}")
    ThousandIsland.Socket.send(socket, <<mean::signed-size(32)>>)
    process_data(rest, socket, store)
  end

  def process_data(<<>>, _socket, store) do
    {store, <<>>}
  end

  def process_data(extra, _socket, store) do
    {store, extra}
  end
end
