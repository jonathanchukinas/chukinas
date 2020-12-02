defmodule Chukinas.Skies.Game.FighterGroup do

  alias Chukinas.Skies.Game.{Fighter, IdAndState, Location}

  # *** *******************************
  # *** TYPES

  # TODO typed struct
  defstruct [
    :id,
    :fighter_ids,
    :state,
    :current_location,
    :from_location,
    :to_location,
  ]

  # TODO remove
  @type fighters :: [Fighter.t()]

  @type t :: %__MODULE__{
    id: integer(),
    fighter_ids: fighters(),
    state: IdAndState.state(),
    current_location: Location.t(),
    from_location: Location.t(),
    to_location: Location.t(),
  }

  # *** *******************************
  # *** NEW

  # TODO if private, defp. Also, rename build_groups?
  @spec build(fighters()) :: t()
  def build([f | _] = fighters) do
    id = fighters
    |> Enum.map(&(&1.id))
    |> Enum.min()
    %__MODULE__{
      id: id,
      fighter_ids: IdAndState.get_list_of_ids(fighters),
      state: f.state,
      current_location: Fighter.get_current_location(f),
      # TODO can I get away from setting these here?
      from_location: f.from_location,
      to_location: f.to_location,
    }
  end

  @spec build_groups(fighters()) :: [t()]
  def build_groups(fighters) do
    fighters
    # TODO is &1.grouping possible (ie no leading &?)
    |> Enum.group_by(&(&1.grouping))
    |> Map.values()
    |> Enum.map(&build/1)
  end

  # *** *******************************
  # *** API

  @spec select(t()) :: t()
  def select(group) do
    state = case group.state do
      :not_avail -> :not_avail
      _ -> :selected
    end
    %{group | state: state}
  end

  @spec unselect(t()) :: t()
  def unselect(group) do
    state = case group.state do
      :selected -> :pending
      _ -> group.state
    end
    %{group | state: state}
  end

end
