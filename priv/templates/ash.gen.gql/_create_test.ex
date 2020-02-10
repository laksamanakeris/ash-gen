defmodule <%= inspect context.web_module %>.Schema.Create<%= inspect schema.alias %>Test do
  use <%= inspect context.web_module %>.ConnCase
  import <%= inspect context.base_module %>.Factory

  @query """
    mutation Create<%= inspect schema.alias %>($<%= schema.singular %>: <%= inspect schema.alias %>Params!) {
      create<%= inspect schema.alias %>(<%= schema.singular %>: $<%= schema.singular %>) {<%= for {k, _v} <- schema.attrs do %>
        <%= k %><% end %>
      }
    }
  """

  test "creates a new <%= schema.singular %>", %{conn: conn} do
    <%= schema.singular %>_params = params_for(:<%= schema.singular %>)

    response = post_gql(conn, %{
      query: @query,
      variables: %{<%= schema.singular %>: <%= schema.singular %>_params}
    })

    assert response == %{
      "data" => %{
        "create<%= inspect schema.alias %>" => %{<%= for {k, _v} <- schema.attrs do %>
          "<%= k %>" => <%= schema.singular %>_params.<%= k %>,<% end %>
        }
      }
    }
  end
end
