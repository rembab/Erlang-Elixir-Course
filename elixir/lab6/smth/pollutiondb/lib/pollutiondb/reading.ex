defmodule Pollutiondb.Reading do
  require Ecto.Query
  use Ecto.Schema
 
  schema "readings" do
      field :date, :date
      field :time, :time
      field :type, :string
      field :value, :float

      belongs_to :station, Pollutiondb.Station
  end

  defp changeset(reading \\ %__MODULE__{}, changesmap) do
    Ecto.Changeset.cast(reading, changesmap, [:date, :time, :type, :value, :station_id])
    |> Ecto.Changeset.validate_required([:date, :time, :type, :value, :station_id])
  end
  
  def add_now(station, type, value) do
    changeset(%{station_id: station.id,
                     type: type, 
                     value: value, 
                     date: Date.utc_today,
                     time: Time.utc_now})
    |> Pollutiondb.Repo.insert
  end

end
