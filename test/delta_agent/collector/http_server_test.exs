defmodule DeltaAgent.Collector.HttpServerTest do
  use ExUnit.Case
  use Plug.Test

  alias DeltaAgent.Collector.HttpServer

  test "greets us with a welcome message" do
    conn = request(:get, "/")

    assert 200 == conn.status
    assert ~s({"message":"Delta Agent says hello 👋"}) == conn.resp_body
  end

  test "collects JSON" do
    conn = request(:post, "/", ~s({"body": "test123"}))

    assert 200 == conn.status
    assert ~s({"message":"Received"}) == conn.resp_body
  end

  describe "returns error" do
    test "on empty json" do
      conn = request(:post, "/", "")

      assert 400 == conn.status
      assert ~s({"error":"Invalid JSON: "}) == conn.resp_body
    end

    test "on invalid json" do
      conn = request(:post, "/", "{test'}")

      assert 400 == conn.status
      assert ~s({"error":"Invalid JSON: {test'}"}) == conn.resp_body
    end

    test "on missing body" do
      conn = request(:post, "/", ~s({"test": "test"}))

      assert 400 == conn.status

      assert ~s({"error":"Please provide a 'body' property: {\\"test\\": \\"test\\"}"}) ==
               conn.resp_body
    end

    test "when page is not found" do
      conn = request(:get, "/foo")

      assert 404 == conn.status
      assert ~s({"error":"Requested page not found!"}) == conn.resp_body
    end
  end

  defp request(method, path, body \\ "") do
    HttpServer.call(conn(method, path, body), %{})
  end
end
