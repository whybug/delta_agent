defmodule DeltaAgent.CollectorTest do
  use ExUnit.Case

  alias DeltaAgent.Collector
  alias DeltaAgent.Collector.Aggregate

  test "batch one operation" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "timestamp": 1543399657}')
    {:ok, batch} = Collector.flush()

    expected = %{
      operations: %{
        "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => "test"
      },
      aggregates: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => %Aggregate{
          hash: "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123"
        }
      },
      usages: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => [
          [1_543_399_657, []]
        ]
      }
    }

    assert expected.operations == batch.operations
    assert expected.aggregates == batch.aggregates
    assert expected.usages == batch.usages
    assert nil !== batch.idempotency_key
  end

  test "aggregates two operations" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "timestamp": 1543399657}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "timestamp": 1543399657}')
    {:ok, batch} = Collector.flush()

    expected = %{
      operations: %{
        "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => "test"
      },
      aggregates: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => %Aggregate{
          hash: "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123"
        }
      },
      usages: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => [
          [1_543_399_657, []],
          [1_543_399_657, []]
        ]
      }
    }

    assert expected.aggregates == batch.aggregates
    assert expected.operations == batch.operations
    assert expected.usages == batch.usages
  end

  test "aggregates multiple operations" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "timestamp": 1543399657}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "timestamp": 1543399657}')
    {:ok} = Collector.collect('{"body": "test2", "schema": "123", "timestamp": 1543399657}')
    {:ok, batch} = Collector.flush()

    expected = %{
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
    }

    assert expected.aggregates == batch.aggregates
    assert expected.operations == batch.operations
    assert expected.usages == batch.usages
  end

  test "aggregates multiple client OSes" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "client": {"os": "ios"}}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok, batch} = Collector.flush()

    expected = %{
      aggregates: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => %Aggregate{
          hash: "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123"
        },
        "57276d67895d36099595bf8c4db058591b48b4d7099b48174fef9ae1cd5f8034" => %Aggregate{
          hash: "57276d67895d36099595bf8c4db058591b48b4d7099b48174fef9ae1cd5f8034",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123",
          client_os: "ios"
        }
      }
    }

    assert expected.aggregates == batch.aggregates
  end

  test "aggregates multiple client versions" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123", "client": {"version": "1.3"}}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok, batch} = Collector.flush()

    expected = %{
      aggregates: %{
        "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230" => %Aggregate{
          hash: "d856dba7965520308959a066dc412402cf0143451a94b5c54cb98ad843789230",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123"
        },
        "9ea489f7618de1df75101ac0a1e034cdcb60a90c1c5619d2126ddcac8903746d" => %Aggregate{
          hash: "9ea489f7618de1df75101ac0a1e034cdcb60a90c1c5619d2126ddcac8903746d",
          operation_hash: "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
          schema: "123",
          client_version: "1.3"
        }
      }
    }

    assert expected.aggregates == batch.aggregates
  end
end
