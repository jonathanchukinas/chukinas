alias Chukinas.Geometry.{Pose, Position, IsPath}

# TODO rename PathLike
defimpl IsPath, for: Pose do

  def pose_start(pose), do: pose

  def pose_end(pose), do: pose

  def len(_pose), do: 0

  # TODO this shouldn't have a margin. Margin is for viewbox alone.
  def get_bounding_rect(pose, _margin) do
    pose |> Position.take() |> Map.merge(%{width: 0, height: 0})
  end
end
