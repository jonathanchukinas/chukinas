alias Chukinas.Dreadnought.{CommandQueue, Command}

defmodule CommandQueue do

  # *** *******************************
  # *** TYPES

  use TypedStruct

  typedstruct enforce: true do
    field :issued_commands, [Command.t()], default: []
    field :default_command_builder, (integer() -> Command.t()
    )  end

  # *** *******************************
  # *** NEW

  def new() do
    default_builder = fn seg_num -> Command.new(segment_number: seg_num) end
    %__MODULE__{
      default_command_builder: default_builder
    }
  end

  # *** *******************************
  # *** API

  def add(
    %__MODULE__{} = command_queue,
    %Command{segment_count: 1, segment_number: segment} = command
  ) do
    {earlier_cmds, later_cmds} =
      command_queue.issued_commands
      |> Enum.split_while(fn cmd -> cmd.segment_number < segment end)
    {_, later_cmds} =
      later_cmds
      |> Enum.split_while(fn cmd -> cmd.segment_number == segment end)
    cmds = Enum.concat([earlier_cmds, [command], later_cmds])
    %{command_queue | issued_commands: cmds}
  end
end
