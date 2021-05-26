alias Chukinas.Geometry.{Pose, Position, Trig}

# pose.ex

defmodule Pose do

  require Position

  use Chukinas.TypedStruct

  typedstruct do
    pose_fields()
  end

  # *** *******************************
  # *** NEW

  def new(%{x: x, y: y, angle: angle}), do: new(x, y, angle)

  def new(%__MODULE__{} = pose), do: pose

  def new({x, y, angle}), do: new(x, y, angle)

  def new({x, y}, angle), do: new(x, y, angle)

  def new(%{x: x, y: y}, angle), do: new(x, y, angle)

  def new(x, y, angle) do
    %__MODULE__{
      x: x,
      y: y,
      angle: Trig.normalize_angle(angle),
    }
  end

  def origin(), do: new(0, 0, 0)


  # *** *******************************
  # *** GETTERS

  def angle(%{angle: angle}), do: angle

  def flip(%{angle: angle} = pose) do
    %__MODULE__{pose | angle: angle + 180}
  end

  def tuple(%{x: x, y: y, angle: angle}), do: {x, y, angle}

  # *** *******************************
  # *** SETTERS

  def put_angle(pose, angle), do: %__MODULE__{pose | angle: angle}

  # TODO this is in the wrong place
  def put_pose(poseable_item, pose) when is_struct(poseable_item) do
    pose = new(pose) |> Map.from_struct
    Map.merge(poseable_item, pose)
  end

  # *** *******************************
  # *** API

  def rotate(%__MODULE__{} = pose, angle) do
    %{pose | angle: Trig.normalize_angle(pose.angle + angle)}
  end

  def straight(pose, length) do
    dx = length * Trig.cos(pose.angle)
    dy = length * Trig.sin(pose.angle)
    new(pose.x + dx, pose.y + dy, pose.angle)
  end

  def left(pose, length) do
    pose
    |> rotate(-90)
    |> straight(length)
  end

  def right(pose, length) do
    pose
    |> rotate(90)
    |> straight(length)
  end

  # *** *******************************
  # *** IMPLEMENTATIONS

  defimpl Inspect do
    import Inspect.Algebra
    require IOP
    def inspect(pose, opts) do
      concat [
        IOP.color("#Pose<"),
        IOP.doc(pose.x |> round),
        ", ",
        IOP.doc(pose.y |> round),
        " ∠ ",
        IOP.doc(round(pose.angle)),
        "°",
        IOP.color(">")
      ]
    end
  end
end
