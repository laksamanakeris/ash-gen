defmodule Mix.Ash.Gql do
  @moduledoc false

  alias Mix.Ash.{Gql, Context, Schema}

  defstruct context: nil,
            schema: nil,
            schema_alias: nil,
            resolver_file: nil,
            types_file: nil,
            create_test_file: nil,
            delete_test_file: nil,
            get_test_file: nil,
            list_test_file: nil,
            update_test_file: nil

  def new(%Context{} = context, %Schema{} = schema) do
    web_prefix = Mix.Ash.web_path(context.context_app)
    test_prefix = Mix.Ash.web_test_path(context.context_app)
    web_path = to_string(schema.web_path)

    schema_alias       = Module.concat([context.web_module, "Schema", schema.alias])
    resolver_file      = Path.join([web_prefix, "schema", web_path, schema.singular, "#{schema.singular}_resolver.ex"])
    types_file         = Path.join([web_prefix, "schema", web_path, schema.singular, "#{schema.singular}_types.ex"])
    create_test_file   = Path.join([test_prefix, "schema", web_path, schema.singular, "create_#{schema.singular}_test.exs"])
    delete_test_file   = Path.join([test_prefix, "schema", web_path, schema.singular, "delete_#{schema.singular}_test.exs"])
    get_test_file   = Path.join([test_prefix, "schema", web_path, schema.singular, "get_#{schema.singular}_test.exs"])
    list_test_file   = Path.join([test_prefix, "schema", web_path, schema.singular, "list_#{schema.plural}_test.exs"])
    update_test_file   = Path.join([test_prefix, "schema", web_path, schema.singular, "update_#{schema.singular}_test.exs"])

    %Gql{
      context: context,
      schema: schema,
      schema_alias: schema_alias,
      resolver_file: resolver_file,
      types_file: types_file,
      create_test_file: create_test_file,
      delete_test_file: delete_test_file,
      get_test_file: get_test_file,
      list_test_file: list_test_file,
      update_test_file: update_test_file,
    }
  end
end
