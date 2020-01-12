Code.require_file("../mix_helper.exs", __DIR__)

defmodule Phoenix.DupContext do
end

defmodule Mix.Tasks.Ash.Gen.ContextTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Ash.Gen
  alias Mix.Ash.{Context, Schema}

  setup do
    Mix.Task.clear()
    :ok
  end

  test "new context", config do
    in_tmp_project(config.test, fn ->
      schema = Schema.new("Blog.Post", "posts", [], [])
      context = Context.new("Blog", schema, [])

      assert %Context{
        alias: Blog,
        base_module: Ash,
        basename: "blog",
        module: Ash.Blog,
        web_module: AshWeb,
        schema: %Mix.Ash.Schema{
          alias: Post,
          human_plural: "Posts",
          human_singular: "Post",
          module: Ash.Blog.Post,
          plural: "posts",
          singular: "post"
        }
      } = context

      assert String.ends_with?(context.dir, "lib/ash/blog")
      assert String.ends_with?(context.file, "lib/ash/blog/_blog.ex")
      assert String.ends_with?(context.test_file, "test/ash/blog_test.exs")
      assert String.ends_with?(context.schema.file, "lib/ash/blog/post.ex")
    end)
  end

  test "new nested context", config do
    in_tmp_project(config.test, fn ->
      schema = Schema.new("Site.Blog.Post", "posts", [], [])
      context = Context.new("Site.Blog", schema, [])

      assert %Context{
        alias: Blog,
        base_module: Ash,
        basename: "blog",
        module: Ash.Site.Blog,
        web_module: AshWeb,
        schema: %Mix.Ash.Schema{
          alias: Post,
          human_plural: "Posts",
          human_singular: "Post",
          module: Ash.Site.Blog.Post,
          plural: "posts",
          singular: "post"
        }
      } = context

      assert String.ends_with?(context.dir, "lib/ash/site/blog")
      assert String.ends_with?(context.file, "lib/ash/site/blog/_blog.ex")
      assert String.ends_with?(context.loader_file, "lib/ash/site/blog/_loader.ex")
      assert String.ends_with?(context.test_file, "test/ash/site/blog_test.exs")
      assert String.ends_with?(context.schema.file, "lib/ash/site/blog/post.ex")
    end)
  end

  test "new existing context", config do
    in_tmp_project(config.test, fn ->
      File.mkdir_p!("lib/ash/blog")

      File.write!("lib/ash/blog/_blog.ex", """
      defmodule Ash.Blog do
      end
      """)

      schema = Schema.new("Blog.Post", "posts", [], [])
      context = Context.new("Blog", schema, [])
      assert Context.pre_existing?(context)
      refute Context.pre_existing_tests?(context)

      File.mkdir_p!("test/ash/blog")

      File.write!(context.test_file, """
      defmodule Ash.BlogTest do
      end
      """)

      assert Context.pre_existing_tests?(context)
    end)
  end

  test "invalid mix arguments", config do
    in_tmp_project(config.test, fn ->
      assert_raise Mix.Error, ~r/Expected the context, "blog", to be a valid module name/, fn ->
        Gen.Context.run(~w(blog Post posts title:string))
      end

      assert_raise Mix.Error, ~r/Expected the schema, "posts", to be a valid module name/, fn ->
        Gen.Context.run(~w(Post posts title:string))
      end

      assert_raise Mix.Error, ~r/The context and schema should have different names/, fn ->
        Gen.Context.run(~w(Blog Blog blogs))
      end

      assert_raise Mix.Error,
        ~r/Cannot generate context Ash because it has the same name as the application/,
        fn ->
          Gen.Context.run(~w(Ash Post blogs))
        end

      assert_raise Mix.Error,
        ~r/Cannot generate schema Ash because it has the same name as the application/,
        fn ->
          Gen.Context.run(~w(Blog Ash blogs))
        end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.Context.run(~w(Blog.Post posts))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.Context.run(~w(Blog Post))
      end
    end)
  end

  test "generates context and handles existing contexts", config do
    in_tmp_project(config.test, fn ->
      Gen.Context.run(~w(Blog Post posts slug:unique title:string))

      assert_file("lib/ash/blog/post.ex", fn file ->
        assert file =~ "field :title, :string"
      end)

      assert_file("lib/ash/blog/_blog.ex", fn file ->
        assert file =~ ~S"""
          def list_posts do
            Repo.all(Post)
          end
        """
        assert file =~ ~S"""
          def get_post!(id), do: Repo.get!(Post, id)
        """
        assert file =~ ~S"""
          def create_post(attrs \\ %{}) do
            %Post{}
            |> Post.changeset(attrs)
            |> Repo.insert()
          end
        """
        assert file =~ ~S"""
          def update_post(%Post{} = post, attrs) do
            post
            |> Post.changeset(attrs)
            |> Repo.update()
          end
        """
        assert file =~ ~S"""
          def delete_post(%Post{} = post) do
            Repo.delete(post)
          end
        """
        assert file =~ ~S"""
          def change_post(%Post{} = post) do
            Post.changeset(post, %{})
          end
        """
      end)

      assert_file("test/ash/blog_test.exs", fn file ->
        assert file =~ "use Ash.DataCase"
        assert file =~ "describe \"posts\" do"
        assert file =~ "def post_fixture(attrs \\\\ %{})"
      end)

      assert [path] = Path.wildcard("priv/repo/migrations/*_create_posts.exs")

      assert_file(path, fn file ->
        assert file =~ "create table(:posts)"
        assert file =~ "add :title, :string"
        assert file =~ "create unique_index(:posts, [:slug])"
      end)

      send(self(), {:mix_shell_input, :yes?, true})
      Gen.Context.run(~w(Blog Comment comments title:string))

      assert_received {:mix_shell, :info,
        ["You are generating into an existing context" <> notice]}

      assert notice =~ "Ash.Blog context currently has 6 functions and 3 files in its directory"
      assert_received {:mix_shell, :yes?, ["Would you like to proceed?"]}

      assert_file("lib/ash/blog/comment.ex", fn file ->
        assert file =~ "field :title, :string"
      end)

      assert_file("test/ash/blog_test.exs", fn file ->
        assert file =~ "use Ash.DataCase"
        assert file =~ "describe \"comments\" do"
        assert file =~ "def comment_fixture(attrs \\\\ %{})"
      end)

      assert [path] = Path.wildcard("priv/repo/migrations/*_create_comments.exs")

      assert_file(path, fn file ->
        assert file =~ "create table(:comments)"
        assert file =~ "add :title, :string"
      end)

      assert_file("lib/ash/blog/_blog.ex", fn file ->
        assert file =~ "def get_comment!"
        assert file =~ "def list_comments"
        assert file =~ "def create_comment"
        assert file =~ "def update_comment"
        assert file =~ "def delete_comment"
        assert file =~ "def change_comment"
      end)
    end)
  end

  test "generates context with no schema", config do
    in_tmp_project(config.test, fn ->
      Gen.Context.run(~w(Blog Post posts title:string --no-schema))

      refute_file("lib/ash/blog/post.ex")

      assert_file("lib/ash/blog/_blog.ex", fn file ->
        assert file =~ "def get_post!"
        assert file =~ "def list_posts"
        assert file =~ "def create_post"
        assert file =~ "def update_post"
        assert file =~ "def delete_post"
        assert file =~ "def change_post"
        assert file =~ "raise \"TODO\""
      end)

      assert_file("test/ash/blog_test.exs", fn file ->
        assert file =~ "use Ash.DataCase"
        assert file =~ "describe \"posts\" do"
        assert file =~ "def post_fixture(attrs \\\\ %{})"
      end)

      assert Path.wildcard("priv/repo/migrations/*_create_posts.exs") == []
    end)
  end
end
