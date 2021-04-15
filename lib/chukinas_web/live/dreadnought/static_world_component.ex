# TODO rename Arena?

defmodule ChukinasWeb.Dreadnought.StaticWorldComponent do
  use ChukinasWeb, :live_component

  # Note: this live component is actually necessary, because I never want its state to getupdated

  def render(assigns) do
    ~L"""
    <div
      id="worldContainer"
      class="fixed inset-0"
      phx-hook="ZoomPanContainer"
    >
      <div
        id="world"
    <%# TODO Pinch %>
        class="relative pointer-events-none bg-cover"
        style="width:<%= @mission_playing_surface.world.width %>px; height: <%= @mission_playing_surface.world.height %>px"
        phx-hook="ZoomPanCover"
      >
        <div
          id="fit"
          class="absolute"
          style="
            left: <%= @mission_playing_surface.margin.width - 50 %>px;
            top: <%= @mission_playing_surface.margin.height - 50 %>px;
            width:<%= @mission_playing_surface.grid.width + 100 %>px;
            height: <%= @mission_playing_surface.grid.height + 100 %>px
          "
          phx-hook="ZoomPanFit"
        >
        </div>
        <svg
          id="svg_islands"
          viewBox="
            <%= -@mission_playing_surface.margin.width %>
            <%= -@mission_playing_surface.margin.height %>
            <%=  @mission_playing_surface.world.width %>
            <%=  @mission_playing_surface.world.height %>
          "
          style="
            width:<%=  @mission_playing_surface.world.width  %>px;
            height:<%= @mission_playing_surface.world.height %>px
          "
        >
          <%= for island <- @mission_playing_surface.islands do %>
          <polygon
            id="island-<%= island.id %>"
            points="
              <%= for point <- island.relative_vertices do %>
              <%= point.x + island.position.x %>
              <%= point.y + island.position.y %>
              <% end %>
            "
            style="fill:green;"
          />
          <% end %>
        </svg>
        <%= render_block @inner_block, socket: @socket, mission_player: @mission_player, margin: @mission_playing_surface.margin, grid: @mission_playing_surface.grid %>
      </div>
    </div>
    """
  end

  def mount(socket), do: {:ok, socket}

end
