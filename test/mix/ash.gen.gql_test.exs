Code.require_file("../mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ash.Gen.GqlTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Ash.Gen
  alias Mix.Ash.{Gql, Context, Schema}

  setup do
    Mix.Task.clear()
    :ok
  end

  test "new gql", config do
    in_tmp_project(config.test, fn ->
      schema = Schema.new("Blog.Post", "posts", [], [])
      context = Context.new("Blog", schema, [])
      gql = Gql.new(context, schema)

      assert gql.schema_alias == AshWeb.Schema.Post
      assert gql.resolver_file == "lib/ash_web/schema/post/post_resolver.ex"
      assert gql.resolver_test_file == "test/ash_web/schema/post/post_resolver_test.exs"
      assert gql.types_file == "lib/ash_web/schema/post/post_types.ex"
    end)
  end

  test "generates a graphql resource", config do
    in_tmp_project(config.test, fn ->
      Gen.Gql.run(~w(Blog Post posts title:string word_count:integer is_draft:boolean author:references:post))

      # assert_file("lib/ash/blog/post.ex", fn file ->
      #   assert file =~ "field :title, :string"
      # end)

      assert_file("lib/ash_web/schema/post/post_resolver.ex", fn file ->
        assert file =~ """
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
            Blog.get_post!(id)
            |> Blog.update_post(post_params)
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
        """
      end)

      assert_file("test/ash_web/schema/post/post_resolver_test.exs")

      assert_file("lib/ash_web/schema/post/post_types.ex", fn file ->
        assert file =~ """
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

          input_object :update_post_params do
            field :title, :string
            field :word_count, :integer
            field :is_draft, :boolean
            field :author, :id
          end

          object :post_queries do
            @desc "A single post"
            field :post, non_null(:post) do
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
        """
      end)
    end)
  end

  test "handles conditional dataloader injection and prompts", config do
    in_tmp_project(config.test, fn ->
      Gen.Gql.run(~w(Blog Post posts title))

      assert_file("lib/ash_web/schema/post/post_types.ex", fn file ->
        assert file =~ """
        defmodule AshWeb.Schema.PostTypes do
          use Absinthe.Schema.Notation
          use Absinthe.Ecto, repo: App.Repo

          alias AshWeb.Schema.PostResolver
        """
      end)
    end)
  end
end
