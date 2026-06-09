defmodule Parser do
  defp parse_datetime(datetime) do
    datetime
    |> String.split("T")
    |> Kernel.then(fn [date, time] ->
      {String.split(date, "-") |> Enum.map(&String.to_integer(&1)) |> :erlang.list_to_tuple(),
       String.split(time, ":")
       |> Enum.drop(-1)
       |> Enum.map(&String.to_integer(&1))
       |> :erlang.list_to_tuple()}
    end)
  end

  defp parse_location(location) do
    location
    |> String.split(",")
    |> Enum.map(&String.to_float(&1))
    |> :erlang.list_to_tuple()
  end

  def parse_line([
        datetime,
        pollutionType,
        pollutionLevel,
        stationID,
        stationName,
        location
      ]) do
    %{
      datetime: parse_datetime(datetime),
      location: parse_location(location),
      stationID: String.to_integer(stationID),
      stationName: stationName,
      pollutionType: pollutionType,
      pollutionLevel: String.to_float(pollutionLevel)
    }
  end

  def parse_data(data) do
    data
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ";"))
    |> Enum.filter(&(length(&1) == 6))
    |> Enum.map(&parse_line(&1))
  end
end
