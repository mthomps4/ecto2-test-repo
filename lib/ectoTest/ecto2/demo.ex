defmodule EctoTest.Demo do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoTest.Demo

  @primary_key {:_id, :string, autogenerate: false}
  schema "ecto" do
    field :name, :string
    embeds_many :reviews, ReviewsSchema
    embeds_one :info, InfoSchema, on_replace: :delete
  end

  def changeset(%Demo{} = demo, attrs) do
    demo
    |> cast(attrs, [:_id, :name])
    |> unique_constraint(:_id)
    |> validate_required([:name])
    |> cast_embed(:reviews)
    |> cast_embed(:info)
  end
end

defmodule ReviewsSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:_id, :string, autogenerate: false}
  embedded_schema do
    field :type, :integer
    field :review, :string
  end

  def changeset(%ReviewsSchema{} = reviews, attrs) do
    reviews
    |> cast(attrs, [:_id, :type, :review])
    |> validate_required([:_id, :type])
  end
end

defmodule InfoSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_one :feeds, FeedsConfig
    embeds_one :days, DaysConfig
  end

  def changeset(%InfoSchema{} = info, attrs) do
    info
    |> cast(attrs, [])
    |> cast_embed(:feeds)
    |> cast_embed(:days)
  end
end

defmodule FeedsConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :on, :boolean
    field :ids, {:array, :string}
  end

  def changeset(%FeedsConfig{} = feeds, attrs) do
    feeds
    |> cast(attrs, [:on, :ids])
  end
end

defmodule DaysConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :week, {:array, :integer}
  end

  def changeset(%DaysConfig{} = days, attrs) do
    days
    |> cast(attrs, [:week])
  end
end

# #### Dummy Mockup
# {
#     "_id": "1234asdf",
#     "name": "ecto_test1",
#     "reviews": [
#         {
#             "_id": "insideId",
#             "type": 1,
#             "review": "something"
#         },
#         {
#             "_id": "insideId2",
#             "type": 2,
#             "review": "needs more"
#         }
#     ],
#     "info":
#         {
#             "feeds": {"on": true, "ids": ["123", "abc", "xyz"]},
#             "days": {"week": [1,2,4]}
#         }
# }
