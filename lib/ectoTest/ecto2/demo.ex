defmodule EctoTest.Demo do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoTest.Demo

  @primary_key {:_id, :string, autogenerate: false}
  schema "ecto" do
    field :name, :string
    embeds_many :reviews, ReviewsSchema
    embeds_one :info, InfoSchema
  end

  def changeset(%Demo{} = demo, attrs) do
    demo
    |> cast(attrs, [
      :_id,
      :name,
      :reviews,
      :info,
    ])
    |> validate_required([:name])
  end
end

defmodule ReviewsSchema do
  use Ecto.Schema
  embedded_schema do
    field :_id, :string
    field :type, :integer
    field :review, :string
  end
end

defmodule InfoSchema do
  use Ecto.Schema
  schema "" do
    embeds_one :feeds, FeedsConfig
    embeds_one :days, DaysConfig
  end
end

defmodule FeedsConfig do
  use Ecto.Schema
  embedded_schema do
    field :on, :boolean
    field :ids, {:array, :string}
  end
end

defmodule DaysConfig do
  use Ecto.Schema
  embedded_schema do
    field :week, {:array, :integer}
  end
end
