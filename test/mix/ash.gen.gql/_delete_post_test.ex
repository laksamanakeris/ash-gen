defmodule AshWeb.Schema.DeletePostTest do
  use AshWeb.ConnCase
  import Ash.Factory

  @query """
    mutation DeletePost($id: ID!) {
      deletePost(id: $id) {
        id
      }
    }
  """

  test "a post can be deleted", %{conn: conn} do
    post = insert(:post)
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: post.id}
    })

    assert response == %{
      "data" => %{
        "deletePost" => %{
          "id" => to_string(post.id)
        }
      }
    }
  end

  test "errors when deleting a nonexistent post", %{conn: conn} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: 0}
    })

    assert response == %{
      "data" => %{"deletePost" => nil},
      "errors" => [%{
        "locations" => [%{"column" => 0, "line" => 2}],
        "message" => "Post not found",
        "path" => ["deletePost"]
      }]
    }
  end
end
