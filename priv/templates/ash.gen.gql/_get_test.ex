defmodule <%= inspect context.web_module %>.Schema.Get<%= inspect schema.alias %>Test do
  use <%= inspect context.web_module %>.ConnCase
  import <%= inspect context.base_module %>.Factory

  @query """
    query Get<%= inspect schema.alias %>($id: ID!) {
      <%= schema.singular %>(id: $id) {
        id<%= for {k, _v} <- schema.attrs do %>
        <%= k %><% end %>
      }
    }
  """

  test "finds a <%= schema.singular %> by id", %{conn: conn} do
    <%= schema.singular %> = insert(:<%= schema.singular %>)
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: <%= schema.singular %>.id}
    })

    assert response == %{
      "data" => %{
        "post" => %{
          "id" => to_string(<%= schema.singular %>.id),<%= for {k, _v} <- schema.attrs do %>
          "<%= k %>" => <%= schema.singular %>.<%= k %>,<% end %>
        }
      }
    }
  end

  test "errors when finding nonexistent <%= schema.singular %> by id", %{conn: conn} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: 0}
    })

    assert response == %{
      "data" => %{"<%= schema.singular %>" => nil},
      "errors" => [%{
        "locations" => [%{"column" => 0, "line" => 2}],
        "message" => "<%= inspect schema.alias %> not found",
        "path" => ["<%= schema.singular %>"]
      }]
    }
  end
end
