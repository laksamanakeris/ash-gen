defmodule AshWeb.Schema.PostResolver do
  alias Ash.Blog
  alias AppWeb.ErrorHelper

  def all(_args, _info) do
    {:ok, Blog.list_posts()}
  end

  def find(%{id: id}, _info) do
    try do
      post = Blog.get_post!(id)
      {:ok, post}
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  def create(args, _info) do
    case Blog.create_post(args) do
      {:ok, post} -> {:ok, post}
      {:error, changeset} -> ErrorHelper.format_errors(changeset)
    end
  end

  def update(%{id: id, post: post_params}, _info) do
    try do
      Blog.get_post!(id)
      |> Blog.update_post(post_params)
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  def delete(%{id: id}, _info) do
    try do
      Blog.get_post!(id)
      |> Blog.delete_post()
    rescue
      error -> {:error, Exception.message(error)}
    end
  end
end
