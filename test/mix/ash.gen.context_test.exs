Code.require_file("../mix_helper.exs", __DIR__)

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
      assert String.ends_with?(context.loader_file, "lib/ash/blog/_blog_loader.ex")
      assert String.ends_with?(context.policy_file, "lib/ash/blog/_blog_policy.ex")
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
      assert String.ends_with?(context.loader_file, "lib/ash/site/blog/_blog_loader.ex")
      assert String.ends_with?(context.policy_file, "lib/ash/site/blog/_blog_policy.ex")
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
          def create_post(attrs \\ %{}) do
            %Post{}
            |> Post.changeset(attrs)
        """
        assert file =~ """
          def fetch_post(id), do: Repo.fetch(Post, id)
        """
        assert file =~ """
          def get_post!(id), do: Repo.get!(Post, id)
        """
        assert file =~ ~S"""
          def list_posts(args \\ %{}) do
            Post
            |> QueryHelpers.build_query(args)
            |> Repo.all
        """
        assert file =~ """
          def update_post(%Post{} = post, attrs) do
            post
            |> Post.changeset(attrs)
        """
        assert file =~ """
          def delete_post(%Post{} = post) do
            Repo.delete(post)
        """
        assert file =~ """
          def change_post(%Post{} = post) do
            Post.changeset(post, %{})
        """
      end)

      assert_file("lib/ash/blog/_blog_loader.ex", fn file ->
        assert file =~ """
        defmodule Ash.Blog.Loader do
          def data do
            Dataloader.Ecto.new(Ash.Repo, query: &build_query/2)
        """
      end)

      assert_file("lib/ash/blog/_blog_policy.ex", fn file ->
        assert file =~ "defmodule Ash.Blog.Policy do"
        assert file =~ "Authorize a user's ability to call Blog actions."
      end)

      assert_file("test/ash/blog_test.exs", fn file ->
        assert file =~ """
        defmodule Ash.BlogTest do
          use Ash.DataCase
          import Ash.Factory

          alias Ash.Blog

          describe "posts" do
            alias Ash.Blog.Post
            @invalid_attrs %{slug: nil, title: nil}

            test "create_post/1 with valid data creates a post" do
              post_params = params_for(:post)

              assert {:ok, %Post{} = post} = Blog.create_post(post_params)
              assert post.slug == post_params.slug
              assert post.title == post_params.title
            end

            test "create_post/1 with invalid data returns error changeset" do
              assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
            end

            test "get_post!/1 returns the post with given id" do
              post = insert(:post)
              assert Blog.get_post!(post.id) == post
            end

            test "list_posts/1 returns all posts" do
              posts = insert_list(3, :post)
              assert Blog.list_posts() == posts
            end

            test "update_post/2 with valid data updates the post" do
              post = insert(:post)
              post_params = params_for(:post, %{slug: "some updated slug", title: "some updated title"})

              assert {:ok, %Post{} = post} = Blog.update_post(post, post_params)
              assert post.slug == post_params.slug
              assert post.title == post_params.title
            end

            test "update_post/2 with invalid data returns error changeset" do
              post = insert(:post)
              assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
              assert post == Blog.get_post!(post.id)
            end

            test "delete_post/1 deletes the post" do
              post = insert(:post)
              assert {:ok, %Post{}} = Blog.delete_post(post)
              assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
            end

            test "change_post/1 returns a post changeset" do
              post = insert(:post)
              assert %Ecto.Changeset{} = Blog.change_post(post)
            end
          end
        end
        """
      end)

      assert [path] = Path.wildcard("priv/repo/migrations/*_create_posts.exs")
      assert_file(path, fn file ->
        assert file =~ "create table(:posts)"
        assert file =~ "add :title, :string"
        assert file =~ "create unique_index(:posts, [:slug])"
      end)

      send self(), {:mix_shell_input, :yes?, true}
      Gen.Context.run(~w(Blog Comment comments title:string))

      assert_received {:mix_shell, :info, ["You are generating into an existing context" <> notice]}
      # assert notice =~ "Ash.Blog context currently has 8 functions and 4 files in its directory"
      assert_received {:mix_shell, :yes?, ["Would you like to proceed?"]}

      assert_file("lib/ash/blog/comment.ex", fn file ->
        assert file =~ "field :title, :string"
      end)

      assert_file("test/ash/blog_test.exs", fn file ->
        assert file =~ "use Ash.DataCase"
        assert file =~ "describe \"comments\" do"
      end)

      assert [path] = Path.wildcard("priv/repo/migrations/*_create_comments.exs")
      assert_file(path, fn file ->
        assert file =~ "create table(:comments)"
        assert file =~ "add :title, :string"
      end)

      assert_file("lib/ash/blog/_blog.ex", fn file ->
        assert file =~ "def get_comment!"
        assert file =~ "def fetch_comment"
        assert file =~ "def list_comments"
        assert file =~ "def create_comment"
        assert file =~ "def update_comment"
        assert file =~ "def delete_comment"
        assert file =~ "def change_comment"
      end)

      # Double check our custom schema files are also being copied since
      # we arent actually using Schema.run to generate the schema files.
      assert_file("test/support/factories/post_factory.ex")
      assert_file("test/support/factory.ex")
    end)
  end

  test "generates context with no schema", config do
    in_tmp_project(config.test, fn ->
      Gen.Context.run(~w(Blog Post posts title:string --no-schema))

      refute_file("lib/ash/blog/post.ex")

      assert_file("lib/ash/blog/_blog.ex", fn file ->
        assert file =~ "def get_post!"
        assert file =~ "def fetch_post"
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
      end)

      assert Path.wildcard("priv/repo/migrations/*_create_posts.exs") == []
    end)
  end
end
