alias Chukinas.Dreadnought.{Unit, Segment, ById}
alias Chukinas.Geometry.{Pose, Size, Position, Turn, Straight, Polygon, Path}
alias Chukinas.Svg

defmodule Unit do
  @moduledoc """
  Represents a ship or some other combat unit
  """

  @size Size.new 140, 40

  # *** *******************************
  # *** TYPES

  use TypedStruct

  typedstruct do
    # ID must be unique within the world
    field :id, integer()
    field :pose, Pose.t()
    # TODO rename world position
    # This places the svg on the correct spot within the World
    field :position, Position.t()
    field :start_pose, Pose.t()
    field :segments, [Segment.t()], default: []
    # TODO rename eg previous_path_svg_string ... or something shorter
    field :path_string, String.t()
  end

  # *** *******************************
  # *** NEW

  def new(id, opts \\ []) do
    fields =
      # TODO I don't like having a default start pose. Make it explicit.
      [
        pose: Pose.new(0, 0, 45),
        start_pose: Pose.new(0, 0, 45)
      ]
      |> Keyword.merge(opts)
      |> Keyword.put(:id, id)
    struct(__MODULE__, fields)
  end

  # *** *******************************
  # *** GETTERS

  def id(unit), do: unit.id
  def start_pose(unit), do: unit.start_pose
  def segment(unit, id), do: unit.segments |> ById.get(id)

  # *** *******************************
  # *** API

  def set_segments(unit, segments) do
    %{unit | segments: segments}
  end

  def move_along_path(unit, path, margin) do
    path |> IOP.inspect("move along pat")
    unit
    |> set_pose(Path.get_end_pose(path), margin)
    |> Map.put(:path_string, Svg.get_path_string(path))
    # TODO I don't like how nested these are.
  end

  # TODO can these two be private?
  def set_pose(unit, pose, margin) do
    %{unit | pose: pose} |> set_position(margin)
  end

  def set_position(%__MODULE__{} = unit, %Size{} = margin) do
    position =
      margin
      |> Size.subtract(Size.multiply @size, 0.5)
      |> Size.to_position
      |> Position.add(unit.pose)
    %{unit | position: position}
  end

  def get_motion_range(%__MODULE__{pose: pose}) do
    max_distance = 300
    min_distance = 200
    angle = 30 # deg
    [
      Straight.new(pose, min_distance),
      Turn.new(pose, min_distance, -angle),
      Turn.new(pose, max_distance, -angle),
      Straight.new(pose, max_distance),
      Turn.new(pose, max_distance, angle),
      Turn.new(pose, min_distance, angle),
    ]
    |> Stream.map(&Path.get_end_pose/1)
    |> Enum.map(&Position.to_tuple/1)
    |> Polygon.new
  end

  # *** *******************************
  # *** IMPLEMENTATIONS

  defimpl Inspect do
    import Inspect.Algebra
    def inspect(unit, opts) do
      unit_map = unit |> Map.take([:id, :pose, :path_string])
      concat ["#Unit<", to_doc(unit_map, opts), ">"]
    end
  end
end
