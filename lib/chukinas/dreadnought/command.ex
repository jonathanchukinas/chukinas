alias Chukinas.Dreadnought.{Command, Segment}
alias Chukinas.Geometry.{Pose}

defmodule Command do

  # *** *******************************
  # *** TYPES

  use TypedStruct

  typedstruct enforce: true do
    field :speed, integer(), default: 3
    field :angle, integer(), default: 0
    field :segment_number, integer(), enforce: false
    field :segment_count, integer(), default: 1
    field :type, atom(), default: :default
  end

  # *** *******************************
  # *** NEW

  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end

  # *** *******************************
  # *** API

  def generate_segments(command, previous_segments) when is_list(previous_segments) do
    start_pose = previous_segments |> List.last() |> Segment.get_end_pose()
    generate_segments(command, start_pose)
  end
  def generate_segments(%__MODULE__{segment_count: 1} = command, %Pose{} = start_pose) do
    [Segment.new(command.speed, command.angle, start_pose, command.segment_number)]
  end

  def set_segment_number(command, segment_number) do
    Map.put(command, :segment_number, segment_number)
  end
end
