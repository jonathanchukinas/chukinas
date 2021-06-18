defmodule Chukinas.Sessions.SessionSupervisor do

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      Chukinas.Sessions.RoomBackup,
      Chukinas.Sessions.RoomRegistry,
      Chukinas.Sessions.RoomDynamicSupervisor,
      Chukinas.Sessions.PlayerRegistry,
      Chukinas.Sessions.PlayerRooms,
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

end
