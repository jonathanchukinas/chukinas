alias Chukinas.Dreadnought.{Mission, Unit}
alias Chukinas.Geometry.{Rect}
alias Chukinas.PositionOrientationSize, as: POS

defmodule DreadnoughtHelpers do
  defmacro __using__(_options) do
    quote do
      alias Chukinas.Dreadnought.{Arena, Mission, Unit, Spritesheet, Sprite}
      alias Chukinas.Geometry.{Rect, Grid}
      alias Chukinas.Svg
      import DreadnoughtHelpers, only: :functions
    end
  end

  # *** *******************************
  # *** API

  def match_numerical_map?(expected, actual) do
    expected = expected |> set_precision()
    actual = Map.take(actual, Map.keys(expected)) |> set_precision()
    Map.equal?(expected, actual)
  end

  def get_margin() do
    10
  end

  # *** *******************************
  # *** BUILDERS

  def unit(), do: Unit.new(1, start_pose: POS.pose_new(0, 500, 0))
  def arena(), do: Rect.from_size(1000, 1000)

  # *** *******************************
  # *** PRIVATE

  # TODO This logic should go into that utility module
  defp set_precision(struct) when is_struct(struct) do
    struct |> Map.from_struct() |> set_precision()
  end
  defp set_precision(%{} = map) do
    map
    |> Enum.map(&set_precision/1)
    |> Map.new()
  end

  defp set_precision({key, value}) do
    {key, set_precision(value)}
  end

  defp set_precision(value) when is_float(value) do
    Float.round(value, 1)
  end

  defp set_precision(value) when is_integer(value) do
    value * 1.0
  end
end
