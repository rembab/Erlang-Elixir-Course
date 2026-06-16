defmodule PollutionDataLoader do
  def stream_file(path \\ "/home/memek/stuff/erlang/elixir/lab6/pollutiondb/AirlyData-ALL-50k.csv") do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing/1)
  end

  def get_station(%{stationID: id, stationName: name, location: location}) do
    %{name: "#{id} #{name}", coords: location}
  end

  def identify_stations(data) do
    data
    |> Stream.uniq_by(& &1.stationID)
    |> Stream.map(&get_station/1)
  end

  def parse_data(data, parsefun, delim) do
    data
    |> Stream.map(&String.split(&1, delim))
    |> Stream.filter(&match?([_, _, _, _, _, _], &1))
    |> Stream.map(parsefun)
  end

  def load_stations(stations) do
    stations
    |> Stream.each(fn station ->
      case Pollutiondb.Station.add(station.name, elem(station.coords, 0), elem(station.coords, 1)) do
        {:ok, _} -> :ok
        {:error, changeset} -> 
          IO.inspect(changeset.errors, label: "Station Insert Failed for #{station.name}")
      end
    end)
    |> Stream.run()
  end

  def load_records(data) do
    db_stations = Pollutiondb.Station.get_all()
    station_id_cache = Enum.into(db_stations, %{}, fn s -> {s.name, s.id} end)

    data
    |> Stream.each(fn record ->
      station_name = "#{record.stationID} #{record.stationName}"
      actual_db_id = Map.get(station_id_cache, station_name)

      if actual_db_id do
        # 1. Extract the tuples
        {y, m, d} = elem(record.datetime, 0)
        {h, min} = elem(record.datetime, 1)

        # 2. Convert Erlang tuples to Elixir Structs for Ecto
        ecto_date = Date.new!(y, m, d)
        ecto_time = Time.new!(h, min, 0)

        # 3. Attempt insert and capture errors
        case Pollutiondb.Reading.add(
          actual_db_id,
          ecto_date,
          ecto_time,
          record.pollutionType,
          record.pollutionLevel
        ) do
          {:ok, _} -> :ok
          {:error, changeset} -> 
            IO.inspect(changeset.errors, label: "Reading Insert Failed")
        end
      else
        IO.puts("Station #{station_name} not found in DB.")
      end
    end)
    |> Stream.run()
  end

  def load_all(path \\ "/home/memek/stuff/erlang/elixir/lab6/pollutiondb/AirlyData-ALL-50k.csv", 
                parsefun \\ &Parser.parse_line/1, 
                delim \\ ";") do
    data = stream_file(path)
    |> parse_data(parsefun, delim)
    
    identify_stations(data)
    |> load_stations()

    load_records(data)
    
  end
end
