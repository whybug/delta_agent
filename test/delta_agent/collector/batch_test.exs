defmodule DeltaAgent.Collector.BatchTest do
  use ExUnit.Case

  alias DeltaAgent.Collector.{Aggregate, Batch}

  test "can be serialized to json" do
    batch = Batch.new(
      operations: %{
        "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => "test",
        "60303ae22b998861bce3b28f33eec1be758a213c86c93c076dbe9f558c11c752" => "test2"
      },
      aggregates: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => %Aggregate{
          hash: "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123"
        },
        "dc54a5ef35b06b3f7155ef4eefe6ec7d1ce6dd066e48956e9ff8f61b746cf495" => %Aggregate{
          hash: "dc54a5ef35b06b3f7155ef4eefe6ec7d1ce6dd066e48956e9ff8f61b746cf495",
          operation_hash: "60303ae22b998861bce3b28f33eec1be758a213c86c93c076dbe9f558c11c752",
          schema: "123"
        }
      },
      usages: %{
        "dc54a5ef35b06b3f7155ef4eefe6ec7d1ce6dd066e48956e9ff8f61b746cf495" => [
          [1_543_399_657, []]
        ],
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => [
          [1_543_399_657, []],
          [1_543_399_657, []]
        ]
      }
    )

    json = Jason.encode!(batch)

    assert nil !== json
  end
end
