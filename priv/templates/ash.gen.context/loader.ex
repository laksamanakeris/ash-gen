defmodule <%= inspect context.module %>.Loader do
  def data do
    Dataloader.Ecto.new(<%= inspect context.base_module %>.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
