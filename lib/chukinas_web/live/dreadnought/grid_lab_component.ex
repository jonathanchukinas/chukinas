defmodule ChukinasWeb.Dreadnought.GridLabComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~L"""
    <div
      id="world"
      class="bg-blue-400 relative"
      style="width:<%= @world.width %>px; height: <%= @world.height %>px"
    >
      WORLD
      <div
        id="arena"
        class="bg-green-300 absolute"
        style="
          left: <%= @margin.width %>px;
          top: <%= @margin.height %>px;
          width:<%= @grid.width %>px;
          height: <%= @grid.height %>px
        "
      >
      ARENA
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

end
