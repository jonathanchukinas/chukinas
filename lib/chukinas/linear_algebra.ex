alias Chukinas.LinearAlgebra
alias Chukinas.LinearAlgebra.{Angle, Vector}
alias Chukinas.LinearAlgebra.VectorCsys, as: Csys
alias Chukinas.Util.Maps

defmodule LinearAlgebra do

  use Chukinas.PositionOrientationSize
  use Chukinas.Math
  alias Vector.Guards
  require Guards


  # *** *******************************
  # *** USING

  defmacro __using__(_opts) do
    # TODO do something with opts
    quote do
      require Chukinas.LinearAlgebra
      import Chukinas.LinearAlgebra
    end
  end


  # *** *******************************
  # *** MACROS

  use TypedStruct

  defmacro csys_fields do
    quote do
      field :orientation, Vector.t, enforce: true
      field :location, Vector.t, enforce: true
    end
  end

  defguard has_csys(csys)
    when is_map_key(csys, :orientation)
    and is_map_key(csys, :location)

  defguard is_coord(vec) when Guards.is_vector(vec)

  defguard is_vector(vec) when Guards.is_vector(vec)

  # *** *******************************
  # *** MERGE

  def merge_csys(map, csys_map), do: Maps.merge(map, csys_map, Csys)

  def merge_csys!(map, csys_map), do: Maps.merge!(map, csys_map, Csys)

  # *** *******************************
  # *** POS

  defdelegate pose_from_csys(csys), to: Csys, as: :pose

  def position_from_coord(coord), do: position_new(coord)

  # *** *******************************
  # *** COORD

  def coord_new(x, y), do: {x, y}

  def coord_origin(), do: coord_new(0, 0)

  def unit_vector_from_vector(vector), do: Vector.normalize(vector)

  def coord_from_position(position), do: position_to_tuple(position)

  # *** *******************************
  # *** CSYS

  def csys_origin, do: pose_origin() |> csys_new

  def csys_from_pose(pose), do: Csys.new(pose)

  defdelegate csys_new(pose_or_csys), to: Csys, as: :new
  def csys_new(x, y, angle), do: pose_new(x, y, angle) |> csys_new

  def csys_from_orientation_and_coord(orientation, coord) do
    Csys.new(orientation, coord)
  end

  defdelegate csys_forward(csys, distance), to: Csys, as: :forward

  def csys_left(csys), do: Csys.rotate(csys, -90)

  def csys_right(csys), do: Csys.rotate(csys, 90)

  def csys_90(csys, signed_number), do: Csys.rotate_90(csys, signed_number)

  def csys_180(csys), do: Csys.rotate(csys, 180)

  def csys_rotate(csys, angle), do: Csys.rotate(csys, angle)

  defdelegate csys_invert(csys), to: Csys, as: :invert

  # *** *******************************
  # *** CSYS -> VECTOR

  def coord_from_csys(csys), do: position_vector_from_csys(csys)

  # replace this with the above *from* functino?
  def coord_of_csys(csys), do: position_vector_from_csys(csys)

  def position_vector_from_csys(csys), do: Csys.location(csys)

  def angle_from_csys_orientation(csys) do
    csys |> Csys.orientation |> Vector.angle
  end

  # *** *******************************
  # *** POSE -> VECTOR

  # TODO rename these e.g. position_vector_forward?
  def vector_forward(pose_or_csys, distance) do
    pose_or_csys
    |> csys_new
    |> csys_forward(distance)
    |> position_vector_from_csys
  end

  def vector_left(pose_or_csys, distance) do
    pose_or_csys
    |> csys_new
    |> csys_left
    |> vector_forward(distance)
  end

  def vector_right(pose_or_csys, distance) do
    pose_or_csys
    |> csys_new
    |> csys_right
    |> vector_forward(distance)
  end

  def vector_90(pose_or_csys, distance, angle) do
    func = case normalize_angle(angle) do
      angle when angle < 180 -> &vector_right/2
      angle when angle > 180 -> &vector_left/2
    end
    func.(pose_or_csys, distance)
  end

  @spec vector_wrt_csys(Vector.t, Csys.t) :: Vector.t
  def vector_wrt_csys(vector, csys) do
    csys
    |> csys_invert
    |> Csys.transform_vector(vector)
  end

  def vector_from_position(position), do: position_to_tuple(position)

  def angle_of_coord_wrt_csys(coord, csys) do
    Angle.of_coord_wrt_csys(coord, csys)
  end

  def vector_from_csys_and_polar(csys, angle, radius) do
    csys
    |> csys_rotate(angle)
    |> csys_forward(radius)
    |> coord_of_csys
  end

  # *** *******************************
  # *** ANGLE

  def angle_from_vector(vector) do
    Angle.from_vector(vector, {1, 0})
  end

  def angle_relative_to_vector(to_vector, from_vector) do
    Angle.from_vector(to_vector, from_vector)
  end

  def angle_between_vectors(a, b), do: Angle.between_vectors(a, b)

  # *** *******************************
  # *** VECTOR

  def vector_origin, do: {0, 0}

  def magnitude_from_vector(vector) do
    Vector.magnitude(vector)
  end

  defdelegate vector_add(a, b), to: Vector, as: :sum

  def vector_subtract(from_vector, vector) do
    Vector.subtract(from_vector, vector)
  end

  # *** *******************************
  # *** CSYS CONVERSIONS

  def vector_transform_from(position, from) when has_position(position) do
    vector_transform_from(position |> coord_from_position, from)
  end

  def vector_transform_from(vector, []), do: vector

  def vector_transform_from(vector, [csys | remaining_csys]) do
    vector
    |> vector_transform_from(csys)
    |> vector_transform_from(remaining_csys)
  end

  def vector_transform_from(vector, pose) when has_pose(pose) do
    vector_transform_from(vector, pose |> csys_from_pose)
  end

  def vector_transform_from(vector, wrt_vector)
  when is_vector(vector)
  and is_vector(wrt_vector) do
    vector_add(vector, wrt_vector)
  end

  def vector_transform_from(vector, csys)
  when is_vector(vector)
  and has_csys(csys) do
    Csys.transform_vector(csys, vector)
  end

  def vector_transform_from(vector, csys) when is_vector(vector) do
    Csys.transform_vector(csys, vector)
  end

  def vector_transform_to(position, to) when has_position(position) do
    vector_transform_to(position |> coord_from_position, to)
  end

  def vector_transform_to(vector, []), do: vector

  def vector_transform_to(vector, [csys | remaining_csys]) do
    vector
    |> vector_transform_to(csys)
    |> vector_transform_to(remaining_csys)
  end

  def vector_transform_to(vector, wrt_vector)
  when is_vector(vector)
  and is_vector(wrt_vector) do
    vector_subtract(vector, wrt_vector)
  end

  def vector_transform_to(vector, pose)
  when has_pose(pose) do
    vector_transform_to(vector, pose |> csys_from_pose)
  end

  def vector_transform_to(vector, csys)
  when is_vector(vector)
  and has_csys(csys) do
    csys
    |> Csys.invert
    |> Csys.transform_vector(vector)
  end

end