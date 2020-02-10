defmodule <%= inspect context.web_module %>.Schema.Delete<%= inspect schema.alias %>Test do
  use <%= inspect context.web_module %>.ConnCase
  import <%= inspect context.base_module %>.Factory

  @query """
    mutation Delete<%= inspect schema.alias %>($id: ID!) {
      delete<%= inspect schema.alias %>(id: $id) {
        id
      }
    }
  """

  @tag :authenticated
  test "a <%= schema.singular %> can be deleted", %{conn: conn} do
    <%= schema.singular %> = insert(:<%= schema.singular %>)
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: <%= schema.singular %>.id}
    })

    assert response == %{
      "data" => %{
        "delete<%= inspect schema.alias %>" => %{
          "id" => to_string(<%= schema.singular %>.id)
        }
      }
    }
  end

  @tag :authenticated
  test "errors when deleting a nonexistent <%= schema.singular %>", %{conn: conn} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: 0}
    })

    assert response == %{
      "data" => %{"delete<%= inspect schema.alias %>" => nil},
      "errors" => [%{
        "locations" => [%{"column" => 0, "line" => 2}],
        "message" => "<%= inspect schema.alias %> not found",
        "path" => ["delete<%= inspect schema.alias %>"]
      }]
    }
  end
end
