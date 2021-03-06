defmodule Chukinas.Dreadnought.MissionBuilder do

  use Chukinas.PositionOrientationSize
  alias Chukinas.Dreadnought.Island
  alias Chukinas.Dreadnought.Mission
  alias Chukinas.Dreadnought.Player
  alias Chukinas.Dreadnought.Unit
  alias Chukinas.Geometry.Grid

  # *** *******************************
  # *** ONLINE GAME

  @spec online(String.t) :: Mission.t
  def online(room_name) do
    {grid, margin} = medium_map()
    Mission.new(room_name, grid, margin)
    |> Map.put(:islands, islands())
    # Still needs players, units, and needs to be started
  end

  def add_player(%Mission{} = mission, player_uuid, player_name) do
    player_id = 1 + Mission.player_count(mission)
    player = Player.new_human(player_id, player_uuid, player_name)
    Mission.put(mission, player)
  end

  def maybe_start(%Mission{} = mission) do
    if ready?(mission) do
      mission
      |> put_fleets
      |> Mission.start
    else
      mission
    end
  end

  @spec ready?(Mission.t) :: boolean
  defp ready?(%Mission{} = mission) do
    with true <- Mission.player_count(mission) in 1..2,
         true <- all_players_ready?(mission) do
      true
    else
      false -> false
    end
  end

  @spec all_players_ready?(Mission.t) :: boolean
  def all_players_ready?(mission) do
    mission
    |> Mission.players
    |> Enum.all?(&Player.ready?/1)
  end

  #@spec each_player_has_at_least_one_unit(Mission.t) :: boolean
  #defp each_player_has_at_least_one_unit(mission) do
  #  units = Mission.units(mission)
  #  mission
  #  |> Mission.player_ids
  #  |> Enum.all?(&Unit.Enum.active_player_unit_count(units, &1) > 0)
  #end

  # *** *******************************
  # *** DEV

  def dev do
    {grid, margin} = medium_map()
    units = [
      Unit.Builder.red_cruiser(1, 1, pose_new(0, 0, 0), name: "Prince Eugene"),
      Unit.Builder.blue_merchant(2, 2, pose_new(position_from_size(grid), 225))
    ]
    Mission.new("dev", grid, margin)
    |> Map.put(:islands, islands())
    |> Mission.put(units)
    |> Mission.put(human_and_ai_players())
    |> Mission.start
  end

  # *** *******************************
  # *** PRIVATE

  defp islands do
    [
      position_new(500, 500),
      position_new(2500, 1200),
      position_new(1500, 1800),
    ]
    |> Enum.with_index
    |> Enum.map(fn {position, index} ->
      position = position_shake position
      Island.random(index, position)
    end)
  end

  def build do
    # Config
    square_size = 50
    arena = %{
      width: 3000,
      height: 2000
    #  width: 700,
    #  height: 400
    }
    margin = size_new(arena.height, arena.width)
    #margin = size_new(200, 100)
    [square_count_x, square_count_y] =
      [arena.width, arena.height]
      |> Enum.map(&round(&1 / square_size))
    grid = Grid.new(square_size, position_new(square_count_x, square_count_y))
    units = [
      Unit.Builder.red_destroyer(1, 1, pose_new(0, 0, 0), name: "Prince Eugene"),
      #Unit.Builder.red_cruiser(2, pose_new(800, 155, 75), name: "Billy"),
      Unit.Builder.blue_merchant(3, 2, pose_new(position_from_size(grid), 225))
    ]
    Mission.new("something...", grid, margin)
    |> Map.put(:islands, islands())
    |> Mission.put(units)
    |> Mission.put(human_and_ai_players())
    |> Mission.start
  end

  def small_map, do: grid_and_margin(800, 500)
  def medium_map, do: grid_and_margin(1400, 700)
  def large_map, do: grid_and_margin(3000, 2000)

  def grid_and_margin(width, height) do
    square_size = 50
    arena = %{
      width: width,
      height: height
    }
    margin = size_new(arena.height, arena.width)
    [square_count_x, square_count_y] =
      [arena.width, arena.height]
      |> Enum.map(&round(&1 / square_size))
    grid = Grid.new(square_size, position_new(square_count_x, square_count_y))
    {grid, margin}
  end

  # *** *******************************
  # *** UNITS

  @spec put_fleets(Mission.t) :: Mission.t
  def put_fleets(%Mission{} = mission) do
    player_ids_and_fleet_colors = Enum.zip([
      Mission.player_ids(mission),
      [:red, :blue],
      # TODO second pose needs to be relative to bl corner of play area
      [pose_new(100, 100, 45), pose_new(500, 500, -135)]
    ])
    Enum.reduce(player_ids_and_fleet_colors, mission, fn {player_id, color, pose}, mission ->
      next_unit_id = Mission.unit_count(mission) + 1
      units = build_fleet(color, next_unit_id, player_id, pose)
      Mission.put(mission, units)
    end)
  end

  def build_fleet(:red, starting_id, player_id, pose) do
    import Unit.Builder
    use Chukinas.LinearAlgebra
    formation =
      [
        {  0,   0},
        {-50,  50},
        {-50, -50},
      ]
    poses = for rel_vector <- formation, do: update_position_translate!(pose, rel_vector)
    [
      red_cruiser(starting_id, player_id, Enum.at(poses, 0), name: "Navarin"),
      red_destroyer(starting_id + 1, player_id, Enum.at(poses, 1), name: "Potemkin"),
      red_destroyer(starting_id + 2, player_id, Enum.at(poses, 2), name: "Sissoi"),
    ]
  end

  def build_fleet(:blue, starting_id, player_id, pose) do
    use Chukinas.LinearAlgebra
    import Unit.Builder
    dreadnought_position =
      pose
      |> csys_from_pose
      |> csys_forward(100)
      |> pose_from_csys
    dreadnought =
      blue_dreadnought(starting_id, player_id, dreadnought_position, name: "Washington")
    destroyer =
      blue_destroyer(starting_id + 1, player_id, dreadnought_position, name: "Detroit")
      |> update_position_translate_right!(75)
    [dreadnought, destroyer]
  end

  # *** *******************************
  # *** COMMON BUILDS

  def human_and_ai_players do
    [
      Player.new_human(1, "PLACEHOLDER", "Billy Jane"),
      Player.new_ai(2, "PLACEHOLDER", "R2-D2")
    ]
  end

end
