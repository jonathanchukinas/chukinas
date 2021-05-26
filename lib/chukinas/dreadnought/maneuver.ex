alias Chukinas.Dreadnought.{Maneuver, UnitAction, Unit}
alias Chukinas.Geometry.{Path, Position}
alias Chukinas.Util.IdList
alias Unit.Event, as: Ev

defmodule Maneuver do
  @moduledoc """
  Fully qualifies a unit's maneuvering for a given turn
  """

  use Chukinas.PositionOrientationSize

  # *** *******************************
  # *** TYPES

  @type t() :: [Ev.Maneuver.t()]

  # *** *******************************
  # *** API

  def get_unit_with_tentative_maneuver(units, maneuver_action, turn_number) do
    unit = units |> IdList.fetch!(maneuver_action.unit_id)
    case UnitAction.value(maneuver_action) do
      %Position{} = pos -> move_to(unit, pos)
        # TODO rename :trapped
      :exit_or_run_aground ->
        unit
        |> put_trapped_maneuver
        |> Unit.put(Ev.Destroyed.by_leaving_arena(turn_number))
    end
  end

  def move_to(unit, position) do
    path = Path.get_connecting_path(pose(unit), position)
    maneuver = Ev.Maneuver.new(path)
    Unit.put(unit, maneuver)
  end

  # *** *******************************
  # *** PRIVATE

  defp put_trapped_maneuver(%Unit{} = unit) do
    this_pose = unit |> pose |> IOP.inspect("put trap man")
    events = [
      Ev.Maneuver.new(Path.new_straight(this_pose, 300))
    ]
    Unit.put(unit, events)
  end
end
