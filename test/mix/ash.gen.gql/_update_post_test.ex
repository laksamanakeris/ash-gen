defmodule AshWeb.Schema.UpdatePostTest do
  use AshWeb.ConnCase
  import Ash.Factory

  @query """
    mutation UpdatePost($id: ID!, $post: PostParams!) {
      updatePost(id: $id, post: $post) {
        id
        title
        word_count
        is_draft
      }
    }
  """

  test "a post can be updated", %{conn: conn} do
    post = insert(:post)
    post_params = params_for(:post, %{
      title: "some updated title",
      word_count: 43,
      is_draft: false,
    })

    response = post_gql(conn, %{
      query: @query,
      variables: %{
        id: post.id,
        post: post_params
      }
    })

    assert response == %{
      "data" => %{
        "updatePost" => %{
          "id" => to_string(post.id),
          "title" => post_params.title,
          "word_count" => post_params.word_count,
          "is_draft" => post_params.is_draft,
        }
      }
    }
  end

  test "errors when updating nonexistent post", %{conn: conn} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{id: "0", post: %{}}
    })

    assert response == %{
      "data" => %{"updatePost" => nil},
      "errors" => [
        %{
          "locations" => [%{"column" => 0, "line" => 2}],
          "message" => "Post not found",
          "path" => ["updatePost"]
        }
      ]
    }
  end
end
