
  import Ecto.Query, warn: false
  import <%= inspect ctx.base %>.Helpers.QueryHelpers, only: [filter_integer_with: 2]

  def filter_with(query, filter) do
    Enum.reduce(filter, query, fn<%= for {k, v} <- schema.attrs do %><%= case v do %><% :boolean -> %>
      {:<%= k %>, <%= k %>}, query ->
        from q in query, where: q.<%= k %> == ^<%= k %><% :integer -> %>
      {:<%= k %>, <%= k %>}, query ->
        filter_integer_with(<%= k %>, query)<% _ -> %>
      {:<%= k %>, <%= k %>}, query ->
        from q in query, where: ilike(q.<%= k %>, ^"%#{<%= k %>}%")<% end %><% end %>
    end)
  end
