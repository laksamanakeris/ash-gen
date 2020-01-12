defmodule <%= inspect context.base_module %>.<%= inspect context.alias %>.Loader do
  def data do
    Dataloader.Ecto.new(base_module.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
