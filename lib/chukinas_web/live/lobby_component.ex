defmodule ChukinasWeb.LobbyComponent do

  use ChukinasWeb, :live_component
  use ChukinasWeb.Components
  alias Chukinas.Dreadnought.Player
  alias Chukinas.Sessions.Room
  alias Chukinas.Sessions.Rooms

  # *** *******************************
  # *** CALLBACKS

  @impl true
  def update(assigns, socket) do
    room = assigns.room
    uuid = assigns.uuid
    players = for player <- Room.players_sorted(room), do: build_player(player, uuid)
    player_self = Room.player_from_uuid(room, uuid)
    socket =
      assign(socket,
        room_name: Room.name(room),
        pretty_room_name: Room.pretty_name(room),
        player_id: Player.id(player_self),
        ready?: Player.ready?(player_self),
        players: players
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_ready", _, socket) do
    Rooms.toggle_ready(socket.assigns.room_name, socket.assigns.player_id)
    {:noreply, socket}
  end

  # *** *******************************
  # *** PRIVATE

  defp build_player(%Player{} = player, uuid) do
    player
    |> Map.from_struct
    |> Map.take(~w/id name ready?/a)
    |> Map.put(:self?, Player.uuid(player) == uuid)
  end

end
