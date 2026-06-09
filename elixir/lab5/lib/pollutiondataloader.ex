defmodule PollutionDataLoader do
  def stream_file(path \\ "/home/memek/stuff/erlang/elixir/lab5/AirlyData-ALL-50k.csv") do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing/1)
  end

  def get_station(%{stationID: id, stationName: name, location: location}) do
    %{name: "#{id} #{name}", coords: location}
  end

  def identify_stations(data) do
    data
    |> Stream.uniq_by(& &1.stationID)
    |> Stream.map(&get_station(&1))
  end

  def parse_data(data, parsefun, delim) do
    data
    |> Stream.map(&String.split(&1, delim))
    |> Stream.filter(&match?([_, _, _, _, _, _], &1))
    |> Stream.map(parsefun)
  end

  def load_stations(stations) do
    stations
    |> Stream.each(&:pollution_gen_server.add_station(&1.name, &1.coords))
    |> Stream.run()
  end

  def load_records(data) do
    data
    |> Stream.each(
      &:pollution_gen_server.add_value(
        &1.location,
        &1.datetime,
        &1.pollutionType,
        &1.pollutionLevel
      )
    )
    |> Stream.run()
  end
end
