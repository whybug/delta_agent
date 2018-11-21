defmodule DeltaAgent.Forwarder.HttpBackend do
  @moduledoc """
  Forwards data to a HTTP backend.
  """
  require Logger

  alias DeltaAgent.Config
  alias HTTPoison.{Error, Response}

  def forward(payload, idempotency_key) do
    Logger.metadata(idempotency_key: idempotency_key)

    with {:ok, encoded_payload} <- encode_json(payload),
         {:ok, compressed_payload} <- gzip(encoded_payload),
         {:ok} <- send_to_backend(compressed_payload, idempotency_key) do
      Logger.debug("Forwarding payload succeeded.")
      {:ok}
    else
      {:retry, message} ->
        Logger.warn("#{message}. Retrying...")
        {:retry, message}

      {:error, message} ->
        Logger.error(message)
        {:error, message}
    end
  end

  defp encode_json(payload) do
    Jason.encode(payload)
  end

  defp gzip(payload) do
    case Config.find(:use_gzip) do
      true ->
        {:ok, :zlib.gzip(payload)}
      false ->
        {:ok, payload}
    end
  end

  defp send_to_backend(payload, idempotency_key) do
    url = <<"#{Config.find(:api_host)}?">>

    Logger.debug(fn -> "Reporting payload to #{url}" end)
    Logger.debug(fn -> "Payload size: #{inspect(:erlang.iolist_size(payload))} bytes" end)

    case HTTPoison.post(url, payload, headers(idempotency_key)) do
      {:ok, %Response{status_code: code}} when code in 200..299 ->
        {:ok}

      {:ok, %Response{status_code: code}} when code in 400..499 ->
        {:error, "Forwarding payload failed with status #{code}"}

      {:ok, %Response{status_code: code}} ->
        {:retry, "Unexpected status: #{inspect(code)}"}

      {:error, %Error{reason: reason}} ->
        {:retry, "Network error: #{inspect(reason)}"}
    end
  end

  defp headers(idempotency_key) do
    [
      {"Agent-Hostname", ""},
      {"User-Agent", "DeltaAgent,version=#{Config.find(:version)}"},
      {"Idempotency-Key", idempotency_key},
      {"Content-Type", "application/json"},
      {"Content-Encoding", if Config.find(:use_gzip) do "gzip" else "none" end}
    ]
  end
end
