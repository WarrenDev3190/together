defmodule Together.Store do
  use GenServer

  @spec start_link(keyword, keyword) :: {:ok, pid}
  def start_link(opts \\ [], gen_server_opts \\ []) do
    case GenServer.start(__MODULE__, opts, gen_server_opts) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Process.link(pid)
        {:ok, pid}
    end
  end

  @spec put(GenServer.server, term, term) :: :ok | no_return
  def put(server, key, value) do
    GenServer.call(server, {:put, key, value})
  end

  @spec get(GenServer.server, term) :: any
  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  @spec pop(GenServer.server, term) :: any
  def pop(server, key) do
    GenServer.call(server, {:pop, key})
  end

  @spec delete(GenServer.server, term) :: :ok
  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  def init(opts) do
    {name, opts} = Keyword.pop(opts, :name, Together.Store.Shards)
    {:ok, ^name = :shards.new(name, opts)}
  end

  def handle_call({:put, key, value}, _from, shards_name) do
    true = :shards.insert(shards_name, [{key, value}])
    {:reply, :ok, shards_name}
  end

  def handle_call({:get, key}, _from, shards_name) do
    {:reply, :shards.lookup(shards_name, key), shards_name}
  end

  def handle_call({:pop, key}, _from, shards_name) do
    value = :shards.lookup(shards_name, key)
    true = :shards.delete(shards_name, key)
    {:reply, value, shards_name}
  end

  def handle_cast({:delete, key}, shards_name) do
    true = :shards.delete(shards_name, key)
    {:noreply, shards_name}
  end
end
