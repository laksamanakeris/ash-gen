defmodule <%= inspect gql.schema_alias %>Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: App.Repo

  <%= if Enum.count(schema.assocs) > 0 do %>import Absinthe.Resolution.Helpers, only: [dataloader: 1]<% end %>

  alias <%= inspect gql.schema_alias %>Resolver

  @desc "A <%= schema.singular %>"
  object :<%= schema.singular %> do
    field :id, :id<%= for {k, v} <- schema.attrs do %>
    field <%= inspect k %>, <%= inspect v %><% end %><%= for {n, _i, _m, _s} <- schema.assocs do %>
    field <%= inspect n %>, <%= inspect n %>, resolve: dataloader(<%= inspect context.alias %>)<% end %>
  end

  input_object :update_<%= schema.singular %>_params do<%= for {k, v} <- schema.attrs do %>
    field <%= inspect k %>, <%= inspect v %><% end %><%= for {_n, i, _m, _s} <- schema.assocs do %>
    field <%= inspect i %>, :id<% end %>
  end

  object :<%= schema.singular %>_queries do
    field :<%= schema.singular %>, non_null(:<%= schema.singular %>) do
      arg :id, non_null(:id)
      resolve &<%= inspect schema.alias %>Resolver.find/2
    end

    field :<%= schema.plural %>, list_of(:<%= schema.singular %>) do
      resolve &<%= inspect schema.alias %>Resolver.all/2
    end
  end

  object :<%= schema.singular %>_mutations do
    field :create_<%= schema.singular %>, :<%= schema.singular %> do<%= for {k, v} <- schema.attrs do %>
      arg <%= inspect k %>, <%= inspect v %><% end %><%= for {_n, i, _m, _s} <- schema.assocs do %>
      arg <%= inspect i %>, :id<% end %>

      resolve &<%= inspect schema.alias %>Resolver.create/2
    end

    field :update_<%= schema.singular %>, :<%= schema.singular %> do
      arg :id, non_null(:id)
      arg :<%= schema.singular %>, :update_<%= schema.singular %>_params

      resolve &<%= inspect schema.alias %>Resolver.update/2
    end

    field :delete_<%= schema.singular %>, :<%= schema.singular %> do
      arg :id, non_null(:id)

      resolve &<%= inspect schema.alias %>Resolver.delete/2
    end
  end
end
