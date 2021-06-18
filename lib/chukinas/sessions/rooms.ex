defmodule Chukinas.Sessions.Rooms do

  alias Chukinas.Sessions.Room
  alias Chukinas.Sessions.RoomDynamicSupervisor
  alias Chukinas.Sessions.RoomJoin
  alias Chukinas.Sessions.RoomRegistry

  # *** *******************************
  # *** GETTERS

  def room_name(%RoomJoin{room_name: value}), do: value

  def room_name(%Room{name: value}), do: value

  # *** *******************************
  # *** API

  def add_member(%RoomJoin{} = room_join) do
    room_join.room_name
    |> room_pid_from_name
    |> GenServer.call({:add_member, room_join})
  end

  def remove_player(room_name, player_uuid) when is_binary(room_name) do
    room_name
    |> room_pid_from_name
    |> GenServer.call({:remove_player, player_uuid})
  end

  def get(room_name) when is_binary(room_name) do
    room_name
    |> room_pid_from_name
    |> GenServer.call(:get)
  end

  def fetch(room_name) do
    case get(room_name) do
      nil -> :error
      room -> {:ok, room}
    end
  end

  def toggle_ready(room_name, player_id) when is_integer(player_id) do
    room_name
    |> room_pid_from_name
    |> GenServer.cast({:toggle_ready, player_id})
  end

  # *** *******************************
  # *** PRIVATE

  defp room_pid_from_name(room_name) when is_binary(room_name) do
    with :error <- RoomRegistry.fetch_pid(room_name),
         {:ok, pid} <- RoomDynamicSupervisor.new_room(room_name) do
      pid
    else
      {:ok, pid} -> pid
    end
  end

end
