defmodule App.Worker do
  use GenServer
  def start_link(init_arg), do: GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  def init(state), do: {:ok, state}
end
