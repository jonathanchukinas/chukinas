defmodule ChukinasWeb.SkiesLiveTest do
  use ChukinasWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, skies_live, disconnected_html} = live(conn, "/skies")
    assert disconnected_html =~ "Skies"
    assert render(skies_live) =~ "Skies"
  end

  test "End Phase btn when all groups are complete", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/skies")
    view
    |> assert_turn(1)
    |> assert_current_phase("Move")
    |> assert_current_phase("Return", false)
    |> assert_disabled("#next_phase")
    |> delay_entry()
    |> end_phase()
    |> assert_turn(2)
  end

  test "delay entry", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/skies")
    view
    |> assert_turn(1)
    |> assert_tp(1)
    |> delay_entry()
    |> assert_tp(0)
  end

  # TODO move asserts into own module
  # TODO move selects into own module
  # TODO display the liveview pid at the top so I can see when it restarts
  defp assert_current_phase(view, phase_name, assert? \\ true) do
    has_element = element(view, "#current_phase") |> render() =~ phase_name
    assert has_element |> flip_bool(assert?)
    view
  end
  defp flip_bool(orig, keep) do
    # TODO is there a better way to do this?
    case keep do
      true -> orig
      false -> !orig
    end
  end
  defp delay_entry(view) do
    view |> element("#delay_entry") |> render_click()
    view
  end
  defp end_phase(view) do
    # TODO rename end_phase
    element(view, "#next_phase") |> render_click()
    view
  end
  defp toggle_fighter(view, fighter_id) do
    element(view, "#fighter_#{fighter_id}") |> render_click()
  end
  defp select_group(view, group_id) do
    element(view, "#group_#{group_id} .select_group") |> render_click()
    view
  end
  defp assert_turn(view, turn_number) do
    assert has_element?(view, "#current_turn", "#{turn_number}")
    view
  end
  defp assert_tp(view, tp) do
    # TODO use text filter, haselement
    assert element(view, "#avail_tp") |> render() =~ "#{tp}"
    view
  end
  defp assert_group_has_unselect_btn(view, group_id, assert? \\ true) do
    has_element = has_element?(view, "#group_#{group_id} .unselect_group")
    has_element = case assert? do
      true -> has_element
      false -> !has_element
    end
    assert has_element
    view
  end
  defp group_has_no_select_btn(view, group_id) do
    assert has_element?(view, "#group_#{group_id} .select_group")
    view
  end
  defp assert_disabled(view, selector) do
    # TODO how do I combine the disabled into the selector?
    assert element(view, selector) |> render() =~ "disabled"
    view
  end

  # TODO
  # test "(un)select", %{conn: conn} do
  #   {:ok, view, _html} = live(conn, "/skies")
  #   refute has_element?(view, "#group_1 .select_group")
  #   toggle_fighter(view, 2)
  #   refute element(view, "#fighter_2") |> render() =~ "checked"
  #   view
  #   |> delay_entry()
  #   |> assert_turn(1)
  #   |> select_group(2)
  #   |> delay_entry()
  #   |> end_phase()
  #   |> assert_turn(2)
  #   |> assert_tp(0)
  # end

  test "squadron buttons and checkboxes works", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/skies")
    refute has_element?(view, "#group_1 .select_group")
    toggle_fighter(view, 2)
    refute element(view, "#fighter_2") |> render() =~ "checked"
    view
    |> delay_entry()
    # TODO the above is copied from above. Extract?
    assert render(view)
    |> String.split("id=\"group_1\"")
    |> Enum.at(1)
    |> String.contains?("id=\"group_2\"")
    [1, 2]
    |> Enum.each(&(group_has_no_select_btn(view, &1)))
    view
    |> select_group(1)
    |> assert_group_has_unselect_btn(1)
    |> assert_group_has_unselect_btn(2, false)
    # TODO clean up
  end

end
