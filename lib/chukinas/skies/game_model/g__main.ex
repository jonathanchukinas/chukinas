defmodule Chukinas.Skies.Game do
  alias Chukinas.Skies.Spec
  alias Chukinas.Skies.Game.{Fighter}

  def init(map_id) do
    # TODO rename do be something like Spec.Map.build...
    state = Spec.build(map_id)
    %{
      spaces: state.spaces,
      elements: state.elements,
      boxes: state.boxes,
      fighters: Enum.map(0..2, &Fighter.new/1)
    }
  end

end