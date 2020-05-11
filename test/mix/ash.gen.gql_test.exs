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
      assert gql.types_file == "lib/ash_web/schema/post/post_types.ex"
      assert gql.create_test_file == "test/ash_web/schema/post/create_post_test.exs"
      assert gql.delete_test_file == "test/ash_web/schema/post/delete_post_test.exs"
      assert gql.get_test_file == "test/ash_web/schema/post/get_post_test.exs"
      assert gql.list_test_file == "test/ash_web/schema/post/list_posts_test.exs"
      assert gql.update_test_file == "test/ash_web/schema/post/update_post_test.exs"
    end)
  end

  test "generates a graphql resource", config do
    {:ok, expected_post_resolver} = File.read("test/mix/ash.gen.gql/_post_resolver.ex")
    {:ok, expected_post_types} = File.read("test/mix/ash.gen.gql/_post_types.ex")
    {:ok, expected_create_post_test} = File.read("test/mix/ash.gen.gql/_create_post_test.ex")
    {:ok, expected_delete_post_test} = File.read("test/mix/ash.gen.gql/_delete_post_test.ex")
    {:ok, expected_get_post_test} = File.read("test/mix/ash.gen.gql/_get_post_test.ex")
    {:ok, expected_list_posts_test} = File.read("test/mix/ash.gen.gql/_list_posts_test.ex")
    {:ok, expected_update_post_test} = File.read("test/mix/ash.gen.gql/_update_post_test.ex")

    in_tmp_project(config.test, fn ->
      Gen.Gql.run(~w(Blog Post posts title:string word_count:integer is_draft:boolean author:references:users))

      assert_file("lib/ash_web/schema/post/post_types.ex", fn file ->
        assert file =~ expected_post_types
      end)

      assert_file("lib/ash_web/schema/post/post_resolver.ex", fn file ->
        assert file =~ expected_post_resolver
      end)

      assert_file("test/ash_web/schema/post/create_post_test.exs", fn file ->
        assert file =~ expected_create_post_test
      end)

      assert_file("test/ash_web/schema/post/delete_post_test.exs", fn file ->
        assert file =~ expected_delete_post_test
      end)

      assert_file("test/ash_web/schema/post/get_post_test.exs", fn file ->
        assert file =~ expected_get_post_test
      end)

      assert_file("test/ash_web/schema/post/list_posts_test.exs", fn file ->
        assert file =~ expected_list_posts_test
      end)

      assert_file("test/ash_web/schema/post/update_post_test.exs", fn file ->
        assert file =~ expected_update_post_test
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
