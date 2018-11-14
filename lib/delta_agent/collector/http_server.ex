defmodule DeltaAgent.Collector.HttpServer do
  @moduledoc """
  HTTP server which sends received data to a collector.
  """
  require Logger

  alias DeltaAgent.Collector

  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  def start_link(port) do
    Logger.info("Listening on HTTP port #{port} 🎉")
    {:ok, _} = Plug.Cowboy.http(__MODULE__, [], port: port)
  end

  get "/" do
    send_json(conn, 200, %{"message" => "Delta Agent says hello 👋"})
  end

  post "/" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, length: 1_000_000)

    case Collector.collect(body) do
      {:ok} ->
        send_json(conn, 200, %{"message" => "Received"})

      {:error, message} ->
        send_json(conn, 400, %{"message" => message})
    end
  end

  match _ do
    send_json(conn, 404, %{"message" => "Requested page not found!"})
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
    send_json(conn, 500, %{"kind" => kind, "reason" => reason.message})
  end

  defp send_json(conn, status, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(message))
  end
end
