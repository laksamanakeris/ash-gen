# Ash

## Mix Phoenix Context & Schema

Phoenix passes two objects that contain necessary info to generate files.
These are examples of the objects.

```
%Mix.Phoenix.Context{
  alias: Blog,
  base_module: Ash,
  basename: "blog",
  context_app: :ash,
  dir: "lib/ash/blog",
  file: "lib/ash/blog.ex",
  generate?: true,
  module: Ash.Blog,
  name: "Blog",
  opts: [],
  schema: %Mix.Phoenix.Schema{
    alias: Post,
    assocs: [],
    attrs: [],
    binary_id: nil,
    context_app: :ash,
    defaults: %{},
    embedded?: false,
    file: "lib/ash/blog/post.ex",
    generate?: true,
    human_plural: "Posts",
    human_singular: "Post",
    indexes: [],
    migration?: true,
    migration_defaults: %{},
    migration_module: Ecto.Migration,
    module: Ash.Blog.Post,
    opts: [],
    params: %{create: %{}, default_key: :some_field, update: %{}},
    plural: "posts",
    repo: Ash.Repo,
    route_helper: "post",
    sample_id: -1,
    singular: "post",
    string_attr: nil,
    table: "posts",
    types: %{},
    uniques: [],
    web_namespace: nil,
    web_path: nil
  },
  test_file: "test/ash/blog_test.exs",
  web_module: AshWeb
}

%Mix.Phoenix.Schema{
  alias: Post,
  assocs: [],
  attrs: [],
  binary_id: nil,
  context_app: :ash,
  defaults: %{},
  embedded?: false,
  file: "lib/ash/blog/post.ex",
  generate?: true,
  human_plural: "Posts",
  human_singular: "Post",
  indexes: [],
  migration?: true,
  migration_defaults: %{},
  migration_module: Ecto.Migration,
  module: Ash.Blog.Post,
  opts: [],
  params: %{create: %{}, default_key: :some_field, update: %{}},
  plural: "posts",
  repo: Ash.Repo,
  route_helper: "post",
  sample_id: -1,
  singular: "post",
  string_attr: nil,
  table: "posts",
  types: %{},
  uniques: [],
  web_namespace: nil,
  web_path: nil
}
```