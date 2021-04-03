defmodule ChukinasWeb.Dreadnought.GridLabComponent do
  use ChukinasWeb, :live_component

  # TODO rename StaticWorldComponent
  # Note: this live component is actually necessary, because I never want its state to getupdated

  @impl true
  def render(assigns) do
    ~L"""
    <div
      id="worldContainer"
      class="fixed inset-0"
      phx-hook="ZoomPanContainer"
    >
      <div
        id="world"
        class="relative pointer-events-none select-none bg-cover"
        style="width:<%= @mission.world.width %>px; height: <%= @mission.world.height %>px"
        phx-hook="ZoomPanCover"
      >
        <div
          id="fit"
          class="absolute"
          style="
            left: <%= @mission.margin.width - 50 %>px;
            top: <%= @mission.margin.height - 50 %>px;
            width:<%= @mission.grid.width + 100 %>px;
            height: <%= @mission.grid.height + 100 %>px
          "
          phx-hook="ZoomPanFit"
        >
        </div>
        <%= live_component @socket,
          ChukinasWeb.Dreadnought.DynamicWorldComponent,
          id: :dynamic_world,
          mission: @mission %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

end
