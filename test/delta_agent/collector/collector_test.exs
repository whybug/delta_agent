defmodule DeltaAgent.CollectorTest do
  use ExUnit.Case

  alias DeltaAgent.Collector

  test "buffers one operation" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok, buffer} = Collector.flush_buffer()

    assert %{"9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => 1} =
             buffer.counts

    assert %{
             "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => %{
               body: "test"
             }
           } = buffer.operations
  end

  test "aggregates one operation" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok, buffer} = Collector.flush_buffer()

    assert %{"9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => 2} =
             buffer.counts

    assert %{
             "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => %{
               body: "test"
             }
           } = buffer.operations
  end

  test "aggregates multiple operations" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok} = Collector.collect('{"body": "test2", "schema": "123"}')
    {:ok, buffer} = Collector.flush_buffer()

    assert %{
             "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => 2,
             "60303ae22b998861bce3b28f33eec1be758a213c86c93c076dbe9f558c11c752" => 1
           } = buffer.counts

    assert %{
             "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" => %{body: "test"},
             "60303ae22b998861bce3b28f33eec1be758a213c86c93c076dbe9f558c11c752" => %{
               body: "test2"
             }
           } = buffer.operations
  end

  test "flushes buffers without errors" do
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok} = Collector.collect('{"body": "test", "schema": "123"}')
    {:ok, _} = Collector.flush_buffer()
  end
end
