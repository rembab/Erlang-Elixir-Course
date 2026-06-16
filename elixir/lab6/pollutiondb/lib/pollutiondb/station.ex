defmodule Pollutiondb.Station do
  require Ecto.Query
  use Ecto.Schema

  schema "stations" do
    field :name, :string
    field :lon, :float
    field :lat, :float
    has_many :readings, Pollutiondb.Reading
  end

  def changeset(station \\ %__MODULE__{}, changesmap) do
    Ecto.Changeset.cast(station, changesmap, [:name, :lon, :lat])
    |> Ecto.Changeset.validate_required([:name, :lon, :lat])
    |> Ecto.Changeset.validate_number(:lat, greater_than: -90, less_than: 90)
    |> Ecto.Changeset.validate_number(:lon, greater_than: 0, less_than: 360) 
  end

  # INSERT
  def add(attrs) when is_map(attrs) do
    changeset(attrs)
    |> Pollutiondb.Repo.insert()
  end

  def add(name, lon, lat) do
    changeset(%{name: name, lon: lon, lat: lat})
    |> Pollutiondb.Repo.insert()
  end

  # SELECT
  def get_all() do
    Pollutiondb.Repo.all(__MODULE__)
  end

  def get_by_id(id) do
    Pollutiondb.Repo.get(__MODULE__, id)
  end

  def find_by_name(name) do
    Pollutiondb.Repo.all(Ecto.Query.where(__MODULE__, name: ^name))
  end

  def find_by_location(lon, lat) do
    Ecto.Query.from(s in __MODULE__, 
      where: s.lon == ^lon,
      where: s.lat == ^lat)
    |> Pollutiondb.Repo.all()
  end

  def find_by_location_range(lon_min, lon_max, lat_min, lat_max) do
    Ecto.Query.from(s in __MODULE__, 
      where: s.lon >= ^lon_min and s.lon <= ^lon_max,
      where: s.lat >= ^lat_min and s.lat <= ^lat_max)
    |> Pollutiondb.Repo.all()
  end

  # UPDATE
  def update_name(station, newname) do
    changeset(station, %{name: newname})
    |> Pollutiondb.Repo.update()
  end

  # DELETE
  def remove(station) do
    Pollutiondb.Repo.delete(station)
  end
end
