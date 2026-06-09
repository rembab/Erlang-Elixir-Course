defmodule Pollution do
  def get_station(%{stationID: id, stationName: name, location: location}) do
    %{name: "#{id} #{name}", coords: location}
  end

  def identify_stations(data) do
    data
    |> Enum.uniq_by(& &1.stationID)
    |> Enum.map(&get_station(&1))
  end

  def load_stations(stations) do
    stations
    |> Enum.each(&:pollution_gen_server.add_station(&1.name, &1.coords))
  end

  def load_records(data) do
    data
    |> Enum.each(
      &:pollution_gen_server.add_value(
        &1.location,
        &1.datetime,
        &1.pollutionType,
        &1.pollutionLevel
      )
    )
  end
end
