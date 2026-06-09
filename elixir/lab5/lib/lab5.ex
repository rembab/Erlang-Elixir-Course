defmodule Lab5 do
  @moduledoc """
  Documentation for `Lab5`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Lab5.hello()
      :world

  """
  def filepath do
    "/home/memek/stuff/erlang/elixir/lab5/AirlyData-ALL-50k.csv"
  end

  def data do
    {:ok, d} = File.read(filepath())
    d
  end

  def parsed_data do
    data()
    |> Parser.parse_data()
  end

  def stations do
    parsed_data()
    |> Pollution.identify_stations()
  end

  def load_stations do
    stations()
    |> Pollution.load_stations()
  end

  def load_records do
    parsed_data()
    |> Pollution.load_records()
  end
end
