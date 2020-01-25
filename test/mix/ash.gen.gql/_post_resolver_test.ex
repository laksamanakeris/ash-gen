defmodule AshWeb.PostResolverTest do
  use AshWeb.ConnCase
  import Ash.PostFactory

  describe "post resolver" do
    test "lists all posts", %{conn: conn} do
      posts = insert_list(3, :post)

      query = """
        {
          posts {
            id
          }
        }
      """

      response = post_gql(conn, %{query: query})

      assert response["data"]["posts"] == to_id_array(posts)
    end

    test "finds a post by id", %{conn: conn} do
      post = insert(:post)

      query = """
        {
          post(id: #{post.id}) {
            id
            title
            word_count
            is_draft
          }
        }
      """

      response = post_gql(conn, %{query: query})

      assert response["data"]["post"] == %{
        "id" => to_string(post.id),
        "title" => post.title,
        "word_count" => post.word_count,
        "is_draft" => post.is_draft,
      }
    end

  test "errors when looking for a nonexistent post by id", %{conn: conn} do
      query = """
        {
          post(id: "doesnt exist") {
            id
          }
        }
      """

      response = post_gql(conn, %{query: query})

      assert response["data"] == nil
      assert response["errors"]
    end

    test "creates a new post", %{conn: conn} do
      post_params = params_for(:post, %{
        title: "some title",
        word_count: 42,
        is_draft: true,
      })

      query = """
        mutation {
          createPost(
            title: #{inspect post_params.title},
            word_count: #{inspect post_params.word_count},
            is_draft: #{inspect post_params.is_draft},
          ) {
            title
            word_count
            is_draft
          }
        }
      """

      response = post_gql(conn, %{query: query})

      assert response["data"]["createPost"] == %{
        "title" => post_params.title,
        "word_count" => post_params.word_count,
        "is_draft" => post_params.is_draft,
      }
    end

    test "updates a post", %{conn: conn} do
      post = insert(:post)

      query = """
        mutation UpdatePost($id: ID!, $post: UpdatePostParams!) {
          updatePost(id:$id, post:$post) {
            id
            title
            word_count
            is_draft
          }
        }
      """

      variables = %{
        id: post.id,
        post: %{
          title: "some updated title",
          word_count: 43,
          is_draft: false,
        }
      }

      response = post_gql(conn, %{query: query, variables: variables})

      assert response["data"]["updatePost"] == %{
        "id" => to_string(post.id),
        "title" => variables.post.title,
        "word_count" => variables.post.word_count,
        "is_draft" => variables.post.is_draft,
      }
    end
  end

  test "deletes a post", %{conn: conn} do
    post = insert(:post)

    query = """
      mutation {
        deletePost(id: #{post.id}) {
          id
        }
      }
    """

    response = post_gql(conn, %{query: query})

    assert response["data"]["deletePost"] == %{
      "id" => to_string(post.id)
    }
  end
end
