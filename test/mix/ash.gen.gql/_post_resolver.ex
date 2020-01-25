defmodule AshWeb.Schema.PostResolver do
  alias AshServer.Accounts

  def all(args, _info) do
    {:ok, Accounts.list_posts(args)}
  end

  def find(%{id: id}, _info) do
    Accounts.fetch_post(id)
  end

  def find(args, _info) do
    case Accounts.get_post_by(args) do
      nil -> {:error, "Can't find a post with given parameters."}
      post -> {:ok, post}
    end
  end

  def create(args, _info) do
    case Accounts.create_post(args) do
      {:ok, post} -> {:ok, post}
      error -> error
    end
  end

  def update(%{id: id, post: post_params}, info) do
    %{current_user: current_user} = info.context

    with {:ok, post} <- Accounts.fetch_post(id) do
      case Accounts.permit(:update_post, current_user, post) do
        :ok -> Accounts.update_post(post, post_params)
        error -> error
      end
    end
  end

  def delete(%{id: id}, info) do
    %{current_user: current_user} = info.context

    with {:ok, post} <- Accounts.fetch_post(id) do
      case Accounts.permit(:delete_post, current_user, post) do
        :ok -> Accounts.delete_post(post)
        error -> error
      end
    end
  end
end
