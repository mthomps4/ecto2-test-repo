defmodule EctoTest.DemoTest do
  use EctoTest.DataCase
  alias EctoTest.Demo

  @valid_entry """
    {
        "_id": "1234asdf",
        "name": "ecto_test1",
        "reviews": [
            {
                "_id": "insideId",
                "type": 1,
                "review": "something"
            },
            {
                "_id": "insideId2",
                "type": 2,
                "review": "needs more"
            }
        ],
        "info":
            {
                "feeds": {"on": true, "ids": ["123", "abc", "xyz"]},
                "days": {"week": [1,2,4]}
            }
    }
  """

  @valid_map_entry %{
    "_id" => "1234asdf",
    "name" => "ecto_test1",
    "info" => %{
      "days" => %{"week" => [1, 2, 4]},
      "feeds" => %{"ids" => ["123", "abc", "xyz"], "on" => true}
      },
    "reviews" => [
      %{"_id" => "insideId", "review" => "something", "type" => 1},
      %{"_id" => "insideId2", "review" => "needs more", "type" => 2}
      ]
    }


  describe "testing CRUD" do
    test "cannot create an empty changeset" do
      cs = Demo.changeset(%Demo{}, %{})
      assert %Ecto.Changeset{
        valid?: false,
        errors: [name: {"can't be blank", []}]
      } = cs
    end

    test "create a valid changeset -- JSON" do
      mapped_info = Poison.decode!(@valid_entry)
      cs = Demo.changeset(%Demo{}, mapped_info)
      first_review = List.first(cs.changes.reviews)
      assert true == cs.changes.info.valid?
      assert true == first_review.valid?
      assert true == cs.valid?
    end

    test "create a valid changeset -- MAP" do
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      first_review = List.first(cs.changes.reviews)
      assert true == cs.changes.info.valid?
      assert true == first_review.valid?
      assert true == cs.valid?
    end

    test "Create a new doc" do
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      assert true == cs.valid?
      IO.inspect cs
      IO.inspect Repo.insert(cs)
    end

  end

end
