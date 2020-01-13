Code.require_file("../mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ash.Gen.SchemaTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Ash.Gen
  # alias Mix.Ash.Schema

  setup do
    Mix.Task.clear()
    :ok
  end

  test "generates additional schema files", config do
    in_tmp_project(config.test, fn ->
      Gen.Schema.run(~w(Blog.Post posts title:string word_count:integer is_draft:boolean author:references:post))

      assert_file("test/support/factory.ex", fn file ->
        assert file =~ """
        defmodule Ash.Factory do
          use ExMachina.Ecto, repo: Ash.Repo

          use Ash.PostFactory
        end
        """
      end)

      assert_file("test/support/factories/post_factory.ex", fn file ->
        assert file =~ """
        defmodule Ash.PostFactory do
          alias Ash.Blog.Post

          defmacro __using__(_opts) do
            quote do
              def post_factory do
                %Post{
                  title: "some title",
                  word_count: 42,
                  is_draft: true,
                }
              end
            end
          end
        end
        """
      end)
    end)
  end

  test("injects factories into factory.ex", config) do
    in_tmp_project(config.test, fn ->
      Gen.Schema.run(~w(Blog.Post posts))
      Gen.Schema.run(~w(Blog.Comment comments))
      Gen.Schema.run(~w(Blog.Video comments))

      assert_file("test/support/factory.ex", fn file ->
        assert file =~ """
        defmodule Ash.Factory do
          use ExMachina.Ecto, repo: Ash.Repo

          use Ash.PostFactory
          use Ash.CommentFactory
          use Ash.VideoFactory
        end
        """
      end)
    end)
  end
end
