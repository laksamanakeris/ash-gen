defmodule AshWeb.Schema.PostTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: App.Repo

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias AshWeb.Schema.PostResolver

  @desc "A post"
  object :post do
    field :id, :id
    field :title, :string
    field :word_count, :integer
    field :is_draft, :boolean
    field :author, :author, resolve: dataloader(Blog)
  end

  @desc "Update post parameters"
  input_object :update_post_params do
    field :title, :string
    field :word_count, :integer
    field :is_draft, :boolean
    field :author, :id
  end

  object :post_queries do
    @desc "A single post"
    field :post, :post do
      arg :id, non_null(:id)
      resolve &PostResolver.find/2
    end

    @desc "A list of posts"
    field :posts, list_of(:post) do
      resolve &PostResolver.all/2
    end
  end

  object :post_mutations do
    @desc "Create a post"
    field :create_post, :post do
      arg :title, :string
      arg :word_count, :integer
      arg :is_draft, :boolean
      arg :author, :id

      resolve &PostResolver.create/2
    end

    @desc "Update a post"
    field :update_post, :post do
      arg :id, non_null(:id)
      arg :post, :update_post_params

      resolve &PostResolver.update/2
    end

    @desc "Delete a post"
    field :delete_post, :post do
      arg :id, non_null(:id)

      resolve &PostResolver.delete/2
    end
  end
