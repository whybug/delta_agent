defmodule DeltaAgent.OperationTest do
  use ExUnit.Case

  alias DeltaAgent.Operation

  @with_defaults %{
    "body" => "example-body",
    "schema" => "some-schema"
  }

  @with_schema %{
    "schema" => "some-schema"
  }

  test "supports only body" do
    data = json(%{"body" => "ListArticles"}, @with_schema)
    {:ok, operation} = Operation.decode(data)

    assert "ListArticles" == operation.body
  end

  test "generates hash for only body" do
    data = json(%{"body" => "ListArticles"}, @with_schema)
    {:ok, operation} = Operation.decode(data)

    assert "2bf83265ad279f0be9a601a6a7237732977cb6b31ff133fa6ea2041d2358aad4" == operation.hash
  end

  test "supports only hash" do
    data =
      json(
        %{"hash" => "2bf83265ad279f0be9a601a6a7237732977cb6b31ff133fa6ea2041d2358aad4"},
        @with_schema
      )

    {:ok, operation} = Operation.decode(data)

    assert "2bf83265ad279f0be9a601a6a7237732977cb6b31ff133fa6ea2041d2358aad4" == operation.hash
    assert nil == operation.body
  end

  test "supports schema" do
    data = json(%{"schema" => "234567890"}, @with_defaults)
    {:ok, operation} = Operation.decode(data)

    assert "234567890" == operation.schema
  end

  test "supports optional timestamp" do
    data = json(%{"timestamp" => 1_543_397_551}, @with_defaults)
    {:ok, operation} = Operation.decode(data)

    assert 1_543_397_551 === operation.timestamp
  end

  test "supports client os" do
    data = json(%{"client" => %{"os" => "ios"}}, @with_defaults)
    {:ok, operation} = Operation.decode(data)

    assert "ios" === operation.client_os
  end

  test "supports client version" do
    data = json(%{"client" => %{"version" => "1.3"}}, @with_defaults)
    {:ok, operation} = Operation.decode(data)

    assert "1.3" === operation.client_version
  end

  test "supports metadata" do
    data = json(%{"metadata" => %{"tag" => "example"}}, @with_defaults)
    {:ok, operation} = Operation.decode(data)

    assert "example" === operation.metadata["tag"]
  end

  test "fails for empty document" do
    assert {:error, :decode, "Invalid JSON"} = Operation.decode('')
  end

  test "fails for empty body" do
    assert {:error, :decode, "Please provide a 'body' or 'hash' and a 'schema' property"} =
             Operation.decode(json(%{"body" => ""}, @with_schema))

    assert {:error, :decode, "Please provide a 'body' or 'hash' and a 'schema' property"} =
             Operation.decode(json(%{"body" => nil}, @with_schema))
  end

  test "fails for empty hash" do
    assert {:error, :decode, "Please provide a 'body' or 'hash' and a 'schema' property"} =
             Operation.decode(json(%{"hash" => ""}, @with_schema))

    assert {:error, :decode, "Please provide a 'body' or 'hash' and a 'schema' property"} =
             Operation.decode(json(%{"hash" => nil}, @with_schema))
  end

  test "fails for empty schema" do
    assert {:error, :decode, "'Schema' property is empty"} =
             Operation.decode(json(%{"hash" => "Some hash", "schema" => ""}))

    assert {:error, :decode, "'Schema' property is empty"} =
             Operation.decode(json(%{"hash" => "Some hash", "schema" => nil}))
  end

  test "fails for unrealistic timestamp" do
    assert {:error, :decode, "Timestamp '123' should be realistic"} =
             Operation.decode(json(%{"timestamp" => 123}, @with_defaults))
  end

  defp json(data, default \\ %{}) do
    Jason.encode!(Map.merge(default, data))
  end
end
