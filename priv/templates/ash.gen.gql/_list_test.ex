defmodule <%= inspect context.web_module %>.Schema.List<%= schema.human_plural %>Test do
  use <%= inspect context.web_module %>.ConnCase
  import <%= inspect context.base_module %>.Factory

  @query """
    query List<%= schema.human_plural %>($filter: <%= inspect schema.alias %>Filter, $orderBy: <%= inspect schema.alias %>OrderBy) {
      <%= schema.plural %>(filter: $filter, orderBy: $orderBy) {
        id
      }
    }
  """

  test "lists all <%= schema.plural %>", %{conn: conn} do
    [a, b] = insert_list(2, :<%= schema.singular %>)
    response = post_gql(conn, %{
      query: @query
    })

    assert response == %{
      "data" => %{
        "<%= schema.plural %>" => [
          %{"id" => to_string(a.id)},
          %{"id" => to_string(b.id)},
        ]
      }
    }
  end
end
