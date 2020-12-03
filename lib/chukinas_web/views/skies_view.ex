defmodule ChukinasWeb.SkiesView do
  use ChukinasWeb, :view
  alias Chukinas.Skies.ViewModel.Phase

  def build_from_list(name, items) do
    # TODO snippet for eex with end
    ~E"""
    <%= for item <- items do %>
    <%= build(name, item) %>
    <% end %>
    """
  end

  def build_component_renderer(vm) do
    fn view_model_key -> render_component(vm, view_model_key) end
  end

  def render_component(key) do
    build Atom.to_string(key)
  end

  def render_component(view_model, key) do
    build Atom.to_string(key), Map.fetch!(view_model, key)
  end

  def build(name, assigns \\ [])
  def build(name, assigns) when is_atom(name) do
    build(Atom.to_string(name), assigns)
  end
  def build(name, assigns) when is_struct(assigns) do
    build(name, Map.from_struct(assigns))
  end
  def build(name, assigns) do
    template = [name, ".html"] |> Enum.join("")
    Phoenix.View.render(__MODULE__, template, assigns)
  end

  # *** *******************************
  # *** TURN MANAGER

  defp phase_class(%Phase{} = phase) do
    case {phase.active?, phase.active_child?} do
      {true, _} -> "bg-blue-100 text-blue-200  font-bold"
      {_, true} -> "bg-blue-100 text-blue-200 font-normal"
      _ -> "font-normal"
    end
  end
  defp subphase_class(%Phase{} = subphase) do
    case subphase.active? do
      true -> "bg-blue-100 text-blue-200 font-bold"
      false -> "font-normal"
    end
  end

  # *** *******************************
  # *** COMPONENTS

  def button_styling(opts \\ []) do
    # TODO this needs reworked
    # TODO - disabled, happy path, other
    opts = Keyword.merge([disabled: false], opts)
    base = """
    hover:bg-blue-300
    text-blue-100 hover:text-blue-100
    font-bold
    py-2 px-4 
    border-2 border-blue-100 rounded
    """
    if Keyword.fetch!(opts, :disabled), do: base <> " opacity-75", else: base
  end

  # def position_box() do
  #   opts = Keyword.merge([disabled: false], opts)
  #   base = """
  #   bg-blue-500 hover:bg-blue-700
  #   text-white font-bold
  #   py-2 px-4 mt-1
  #   border border-blue-700 rounded
  #   """
  #   if Keyword.fetch!(opts, :disabled), do: base <> " opacity-50", else: base
  # end

end

# https://bernheisel.com/blog/phoenix-liveview-and-views
# https://fullstackphoenix.com/tutorials/nested-templates-and-layouts-in-phoenix-framework
