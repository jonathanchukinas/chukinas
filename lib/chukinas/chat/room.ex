require IEx

defmodule Chukinas.Chat.Room do
  use GenServer, restart: :temporary
  alias Chukinas.User
  alias Chukinas.Chat.Users
  alias Chukinas.Chat.Room
  # TODO replace
  alias Chukinas.Chat.Room.Registry, as: RoomRegistry

  #############################################################################
  # STATE
  #############################################################################

    @enforce_keys k = [:name]
    defstruct k ++ [msgs: [], users: Users.new()]

  #############################################################################
  # CLIENT API
  #############################################################################

  # @spec build_child_spec(String.t()) :: Supervisor.child_spec()
  # def build_child_spec(room_name) do
  #   __MODULE__.child_spec(room_name)
  #   |> Supervisor.child_spec(id: room_name, restart: :transient)
  # end

  def start_link(room_name) do
    GenServer.start_link(__MODULE__, room_name, [])
  end

  def upsert_user(room_name, user) do
    call(room_name, {:upsert_user, user})
  end

  def add_msg(room_name, msg) do
    call(room_name, {:add_msg, msg})
  end

  #############################################################################
  # SERVER CALLBACKS
  #############################################################################

  @impl GenServer
  def init(room_name) do
    state = %Room{name: room_name}
    {:ok, state, {:continue, :notify}}
  end

  @impl GenServer
  def handle_call({:add_msg, msg}, _from, %Room{} = state) do
    msgs = [msg | state.msgs]
    state = Map.put(state, :msgs, msgs)
    {:reply, state, state, {:continue, :notify}}
  end

  @impl GenServer
  def handle_call({:upsert_user, user}, _from, state) do
    users = Users.upsert(state.users, user)
    state = Map.put(state, :users, users)
    {:reply, state, state, {:continue, :notify}}
  end

  @impl GenServer
  def handle_continue(:notify, state) do
    state.users
    |> Users.as_list()
    |> Enum.each(fn u -> notify(u, state) end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, object, _reason}, state) do
    users = Users.remove_pid(state.users, object)
    state = Map.put(state, :users, users)
    {:noreply, state, {:continue, :notify}}
  end

  #############################################################################
  # HELPERS
  #############################################################################

  defp call(room_name, request) do
    pid = RoomRegistry.get_room(room_name)
    GenServer.call(pid, request)
    :ok
  end

  defp notify(user, state) do
    msg = {:state_update, user, state}
    User.send(user, msg)
  end
end