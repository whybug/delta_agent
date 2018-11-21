defmodule DeltaAgent.Collector.HttpServerTest do
  use ExUnit.Case
  use Plug.Test

  alias DeltaAgent.Collector.HttpServer

  test "greets us with a welcome message" do
    conn = conn(:get, "/") |> HttpServer.call(%{})

    assert 200 == conn.status
    assert ~s({"message":"Delta Agent says hello 👋"}) == conn.resp_body
  end

  test "collects JSON" do
    conn = conn(:post, "/", ~s({"body": "test123"})) |> HttpServer.call(%{})

    assert 200 == conn.status
    assert ~s({"message":"Received"}) == conn.resp_body
  end

  describe "returns error" do
    test "on empty json" do
      conn = conn(:post, "/", "") |> HttpServer.call(%{})

      assert 400 == conn.status
      assert ~s({"error":"Invalid JSON: "}) == conn.resp_body
    end

    test "on invalid json" do
      conn = conn(:post, "/", "{test'}") |> HttpServer.call(%{})

      assert 400 == conn.status
      assert ~s({"error":"Invalid JSON: {test'}"}) == conn.resp_body
    end

    test "on missing body" do
      conn = conn(:post, "/", ~s({"test": "test"})) |> HttpServer.call(%{})

      assert 400 == conn.status
      assert ~s({"error":"Please provide a 'body' property: {\\"test\\": \\"test\\"}"}) == conn.resp_body
    end

    test "when page is not found" do
      conn = conn(:get, "/foo") |> HttpServer.call(%{})

      assert 404 == conn.status
      assert ~s({"error":"Requested page not found!"}) == conn.resp_body
    end
  end

end
