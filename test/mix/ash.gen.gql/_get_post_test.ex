defmodule AshWeb.Schema.GetPostTest do
  use AshWeb.ConnCase
  import Ash.Factory

  @query """
    query GetPost($id: ID!) {
      post(id: $id) {
        id
        title
        word_count
        is_draft
      }
    }
  """

  test "finds a post by id", %{conn: conn} do
    post = insert(:post)
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: post.id}
    })

    assert response == %{
      "data" => %{
        "post" => %{
          "id" => to_string(post.id),
          "title" => post.title,
          "word_count" => post.word_count,
          "is_draft" => post.is_draft,
        }
      }
    }
  end

  test "errors when finding nonexistent post by id", %{conn: conn} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: 0}
    })

    assert response == %{
      "data" => %{"post" => nil},
      "errors" => [%{
        "locations" => [%{"column" => 0, "line" => 2}],
        "message" => "Post not found",
        "path" => ["post"]
      }]
    }
  end
end
