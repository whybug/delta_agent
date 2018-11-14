defmodule DeltaAgent.OperationTest do
  use ExUnit.Case

  alias DeltaAgent.Operation

  test "fails for empty document" do
    assert {:error, :decode, _} = Operation.decode('')
  end

  test "parses operation definition" do
    data = ~c({
      "body": "ListArticles"
    })
    {:ok, operation} = Operation.decode(data)

    assert "ListArticles" = operation.body
    assert "2bf83265ad279f0be9a601a6a7237732977cb6b31ff133fa6ea2041d2358aad4" = operation.hash
  end
end
