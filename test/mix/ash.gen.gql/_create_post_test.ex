defmodule AshWeb.Schema.CreatePostTest do
  use AshWeb.ConnCase
  import Ash.Factory

  @query """
    mutation CreatePost($post: PostParams!) {
      createPost(post: $post) {
        title
        word_count
        is_draft
      }
    }
  """

  test "creates a new post", %{conn: conn} do
    post_params = params_for(:post)

    response = post_gql(conn, %{
      query: @query,
      variables: %{post: post_params}
    })

    assert response == %{
      "data" => %{
        "createPost" => %{
          "title" => post_params.title,
          "word_count" => post_params.word_count,
          "is_draft" => post_params.is_draft,
        }
      }
    }
  end
end
