
  import Ecto.Query, warn: false

  def filter_with(query, filter) do
    Enum.reduce(filter, query, fn<%= for {k, _v} <- schema.attrs do %>
      {:<%= k %>, <%= k %>}, query ->
        from q in query, where: ilike(q.<%= k %>, ^"%#{<%= k %>}%")<% end %>
    end)
  end
