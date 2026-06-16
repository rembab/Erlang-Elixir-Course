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

  def add(station_id, date, time, type, value) do
    changeset(%{station_id: station_id,
                type: type, 
                value: value, 
                date: date,
                time: time})
    |> Pollutiondb.Repo.insert
  end

  def find_by_date(date) do
    Ecto.Query.from(s in __MODULE__, 
      where: s.date == ^date)
    |> Pollutiondb.Repo.all()
  end
end
