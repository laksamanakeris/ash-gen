# Ash

Set of opinionated generators for Phoenix & Absinthe. Creates contexts with
dataloader and a authorization policy as well as resolver, types and tests
for graphql resources.

Takes similar arguments to `mix phx.gen.context` and creates a graphgql resource. Untested on anything other than simple types lieke strings, integers and booleans.


## Mix Ash Context & Schema

Borrowed from the Phoenix generators where they pass objects that contain 
necessary info to generate files. These are examples of the objects. Will
move this out after I stop referencing it so much ha

```
%Mix.Ash.Context{
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
  schema: %Mix.Ash.Schema{
    alias: Post,
    assocs: [],
    attrs: [title: :string, word_count: :integer, is_draft: :boolean],
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

%Mix.Ash.Schema{
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
