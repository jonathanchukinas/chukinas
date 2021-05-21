defmodule ChukinasWeb.DreadnoughtLive do
  use ChukinasWeb, :live_view
  alias ChukinasWeb.DreadnoughtView

  #@impl true
  #def render(assigns) do
  #  DreadnoughtView.render("layout_menu.html", assigns)
  #end

  def render_template(template, assigns) do
    DreadnoughtView.render(template, assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {ChukinasWeb.LayoutView, "dreadnought_menu.html"}}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = case socket.assigns.live_action do
      nil -> redirect(socket, to: "/dreadnought/play")
        _ -> socket
    end
    socket = case {params, socket.assigns} do
      {%{"room" => room}, _} -> assign(socket, room: room, room_name: ChukinasWeb.Plugs.SanitizeRoomName.unslugify(room))
      {_, %{room: _room}} -> socket
      _ -> assign(socket, room: nil, room_name: nil)
    end
    |> IOP.inspect("dread live params")
    |> standard_assigns
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_show_markers", _, socket) do
    socket = assign(socket, show_markers?: !socket.assigns.show_markers?)
    {:noreply, socket}
  end

  def standard_assigns(socket) do
    live_action = socket.assigns.live_action
    tabs = [
      %{title: "Play", live_action: :play, current?: false},
      %{title: "Gallery", live_action: :gallery, current?: false},
    ]
    |> Enum.map(fn tab ->
      case tab.live_action do
        ^live_action -> %{tab | current?: true}
        _ -> %{tab | current?: false}
      end
    end)
    title = case Enum.find(tabs, & &1.live_action == live_action) do
      %{title: title} -> title
      nil -> nil
    end
    page_title = case title do
      nil -> "Dreadnought"
      title -> "Dreadnought | #{title}"
    end
    assign(socket,
      tabs: tabs,
      page_title: page_title,
      header: title
    )
  end
end
