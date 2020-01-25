defmodule AshWeb.Schema.PostResolver do
  alias Ash.Blog

  def all(args, _info) do
    {:ok, Blog.list_posts(args)}
  end

  def find(%{id: id}, _info) do
    Blog.fetch_post(id)
  end

  def find(args, _info) do
    case Blog.get_post_by(args) do
      nil -> {:error, "Can't find a post with given parameters."}
      post -> {:ok, post}
    end
  end

  def create(args, _info) do
    case Blog.create_post(args) do
      {:ok, post} -> {:ok, post}
      error -> error
    end
  end

  def update(%{id: id, post: post_params}, info) do
    %{current_user: current_user} = info.context

    with {:ok, post} <- Blog.fetch_post(id) do
      case Blog.permit(:update_post, current_user, post) do
        :ok -> Blog.update_post(post, post_params)
        error -> error
      end
    end
  end

  def delete(%{id: id}, info) do
    %{current_user: current_user} = info.context

    with {:ok, post} <- Blog.fetch_post(id) do
      case Blog.permit(:delete_post, current_user, post) do
        :ok -> Blog.delete_post(post)
        error -> error
      end
    end
  end
end
