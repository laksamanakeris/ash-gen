defmodule <%= inspect context.web_module %>.Schema.Update<%= inspect schema.alias %>Test do
  use <%= inspect context.web_module %>.ConnCase
  import <%= inspect context.base_module %>.Factory

  @query """
    mutation Update<%= inspect schema.alias %>($id: ID!, $<%= schema.singular %>: <%= inspect schema.alias %>Params!) {
      update<%= inspect schema.alias %>(id: $id, <%= schema.singular %>: $<%= schema.singular %>) {
        id<%= for {k, _v} <- schema.attrs do %>
        <%= k %><% end %>
      }
    }
  """

  @tag :authenticated
  test "a <%= schema.singular %> can be updated", %{conn: conn} do
    <%= schema.singular %> = insert(:<%= schema.singular %>)
    <%= schema.singular %>_params = params_for(:<%= schema.singular %>, %{<%= for {k, _v} <- schema.attrs do %>
      <%= k %>: <%= inspect Map.get(schema.params.update, k) %>,<% end %>
    })

    response = post_gql(conn, %{
      query: @query,
      variables: %{
        id: <%= schema.singular %>.id,
        <%= schema.singular %>: <%= schema.singular %>_params
      }
    })

    assert response == %{
      "data" => %{
        "update<%= inspect schema.alias %>" => %{
          "id" => to_string(<%= schema.singular %>.id),<%= for {k, _v} <- schema.attrs do %>
          "<%= k %>" => <%= schema.singular %>_params.<%= k %>,<% end %>
        }
      }
    }
  end

  @tag :authenticated
  test "errors when updating nonexistent post", %{conn: conn} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: "0", post: %{}}
    })

    assert response == %{
      "data" => %{"update<%= inspect schema.alias %>" => nil},
      "errors" => [
        %{
          "locations" => [%{"column" => 0, "line" => 2}],
          "message" => "<%= inspect schema.alias %> not found",
          "path" => ["update<%= inspect schema.alias %>"]
        }
      ]
    }
  end
end
