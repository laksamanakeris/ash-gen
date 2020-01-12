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

  test "generates context and handles existing contexts", config do
    in_tmp_project(config.test, fn ->
      Gen.Gql.run(~w(Blog Post posts title:string word_count:integer is_draft:boolean))

      # assert_file("lib/ash/blog/post.ex", fn file ->
      #   assert file =~ "field :title, :string"
      # end)

      assert_file("lib/ash_web/schema/post/post_resolver.ex")
      assert_file("test/ash_web/schema/post/post_resolver_test.exs")

      assert_file("lib/ash_web/schema/post/post_types.ex", fn file ->
        assert file =~ """
        defmodule AshWeb.Schema.PostTypes do
          use Absinthe.Schema.Notation
          use Absinthe.Ecto, repo: App.Repo

          alias AshWeb.Schema.PostResolver

          @desc "A post"
          object :post do
            field :id, :id
            field :title, :string
            field :word_count, :integer
            field :is_draft, :boolean
          end

          input_object :update_post_params do
            field :title, :string
            field :word_count, :integer
            field :is_draft, :boolean
          end

          object :post_queries do
            field :post, non_null(:post) do
              arg :id, non_null(:id)
              resolve &PostResolver.find/2
            end

            field :posts, list_of(:post) do
              resolve &PostResolver.all/2
            end
          end

          object :post_mutations do
            field :create_post, :post do
              arg :title, :string
              arg :word_count, :integer
              arg :is_draft, :boolean

              resolve &PostResolver.create/2
            end

            field :update_post, :post do
              arg :id, non_null(:id)
              arg :post, :update_post_params

              resolve &PostResolver.update/2
            end

            field :delete_post, :post do
              arg :id, non_null(:id)

              resolve &PostResolver.delete/2
            end
          end
        """
      end)
    end)
  end
end
