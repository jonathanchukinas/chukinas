defmodule Chukinas.Skies.ViewModel.GroupPawn do

  alias Chukinas.Skies.Game.FighterGroup, as: G_FighterGroup

  # *** *******************************
  # *** TYPES

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer()
    field :uiid, String.t()
  end

  # *** *******************************
  # *** BUILD

  @spec build(G_FighterGroup.t()) :: t()
  def build(group) do
    %__MODULE__{
      id: group.id,
      uiid: "pawn_group_#{group.id}",
    }
  end

end