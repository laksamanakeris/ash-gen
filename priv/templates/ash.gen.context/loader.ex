defmodule <%= inspect context.module %>.Loader do
  def data do
    Dataloader.Ecto.new(<%= inspect context.base_module %>.Repo, query: &build_query/2)
  end

  defp build_query(query, _params) do
    query
  end
end
