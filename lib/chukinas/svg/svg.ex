alias Chukinas.Util.Precision
alias Chukinas.Geometry.{Straight, Path, Position, Rect, Turn, Trig}
alias Chukinas.Svg.{Interpret, Parse}

defmodule Chukinas.Svg do
  @moduledoc"""
  This module converts path structs to svg path strings for use in eex templates.
  """

  require Position

  # *** *******************************
  # *** API

  @doc"""
  Convert a path struct to a svg path string that can be dropped into an eex template.
  """
  def get_path_string(%Straight{} = path) do
    {x0, y0} = get_start_coord(path)
    {x, y} = get_end_coord(path)
    "M #{x0} #{y0} L #{x} #{y}"
  end
  def get_path_string(%Turn{} = path) do
    {x0, y0} = get_start_coord(path)
    "M #{x0} #{y0} #{get_quadratic_curve(path)}"
  end

  def scale(svg_path, scale) when is_binary(svg_path) and is_integer(scale) do
    svg_path
    |> Parse.parse
    |> Interpret.to_positions
  end

  # *** *******************************
  # *** PRIVATE

  defp get_start_coord(path) do
    path
    |> Path.get_start_pose()
    |> Position.to_int_tuple()
  end

  defp get_end_coord(path) do
    path
    |> Path.get_end_pose()
    |> Position.to_int_tuple()
  end

  defp get_quadratic_curve(%Turn{angle: angle} = path) when abs(angle) <= 90 do
    radius = Turn.get_radius path
    half_angle_rad = abs(Trig.deg_to_rad(angle)) / 2
    length_to_intercept = radius * :math.tan(half_angle_rad)
    {dx, dy} =
      path
      |> Path.get_start_pose()
      |> Path.new_straight(length_to_intercept)
      |> Path.get_end_pose()
      |> Position.to_int_tuple()
    {x1, y1} = get_end_coord(path)
    "Q #{dx} #{dy} #{x1} #{y1}"
  end
  defp get_quadratic_curve(%Turn{} = path) do
    {right_angle_turn, remaining_turn} = Turn.split(path, 90)
    "#{get_quadratic_curve right_angle_turn} #{get_quadratic_curve remaining_turn}"
  end
end
