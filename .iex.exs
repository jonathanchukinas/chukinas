# Load global config
import_file_if_available("~/.iex.exs")

alias Chukinas.User
alias Chukinas.Users
alias Chukinas.Chat.Room
alias Chukinas.Chat.Room.Registry, as: RoomRegistry
alias Chukinas.Insider.API, as: I

# {:ok, pid} = StateMachine.start_link()

room_name = "yellow"
user = %User{name: "Jonathan", pids: [self()], uuid: self()}
I.flip(room_name, user)

# alias C, as: C
# C.start_link
# C.inc
