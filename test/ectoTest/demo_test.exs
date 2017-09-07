defmodule EctoTest.DemoTest do
  use EctoTest.DataCase
  alias EctoTest.Demo

  @valid_entry """
    {
        "_id": "#{Ecto.UUID.generate}",
        "name": "ecto_test1",
        "reviews": [
            {
                "_id": "uniq-insideId",
                "type": 1,
                "review": "something"
            },
            {
                "_id": "uniq-insideId2",
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
    "_id" => "#{Ecto.UUID.generate}",
    "name" => "ecto_test1",
    "info" => %{
      "days" => %{"week" => [1, 2, 4]},
      "feeds" => %{"ids" => ["123", "abc", "xyz"], "on" => true}
      },
    "reviews" => [
      %{"_id" => "uniq-insideId", "review" => "something", "type" => 1},
      %{"_id" => "uniq-insideId2", "review" => "needs more", "type" => 2}
      ]
    }

  @bad_review_type_entry %{
    "_id" => "#{Ecto.UUID.generate}",
    "name" => "ecto_test1",
    "info" => %{
      "days" => %{"week" => [1, 2, 4]},
      "feeds" => %{"ids" => ["123", "abc", "xyz"], "on" => true}
      },
    "reviews" => [
      %{"_id" => "uniq-insideId", "review" => "something", "type" => "string"},
      %{"_id" => "uniq-insideId2", "review" => "needs more", "type" => "string2"}
      ]
    }

  describe "testing CRUD" do
    test "cannot create an empty changeset" do
      cs = Demo.changeset(%Demo{}, %{})
      assert %Ecto.Changeset{
        valid?: false,
        errors: [name: {"can't be blank", [validation: :required]}]
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

    test "create a bad nested changeset -- MAP" do
      cs = Demo.changeset(%Demo{}, @bad_review_type_entry)
      first_review = List.first(cs.changes.reviews)
      assert true == cs.changes.info.valid?
      assert false == first_review.valid?
      assert false == cs.valid?
    end

    test "Create a new doc" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      assert true == cs.valid?
      {staus, value} = Repo.insert(cs)
      assert staus == :ok
      assert value.info.feeds.ids == ["123", "abc", "xyz"]
    end

    test "Update a Doc -- embeds_one" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      assert true == cs.valid?
      main_doc = Repo.insert!(cs)
      main_id = main_doc._id
      doc = Repo.get!(Demo, main_id)
      # Can only do Embeded Changesets with Primary ID
      changes = %{
        info: %{
          days: %{week: [1, 2, 3, 4]},
          feeds: %{ids: ["123", "456"], on: false}
          },
        }
      updated_cs = Demo.changeset(doc, changes)
      Repo.update!(updated_cs)
      updated_doc = Repo.get!(Demo, main_id)
      assert updated_doc.info == %InfoSchema{
                                    days: %DaysConfig{week: [1, 2, 3, 4]},
                                    feeds: %FeedsConfig{ids: ["123", "456"], on: false}
                                  }
    end

    test "Update a Doc -- embeds_many" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      assert true == cs.valid?
      main_doc = Repo.insert!(cs)
      main_id = main_doc._id
      doc = Repo.get!(Demo, main_id)
      # Can only do Embeded Changesets with Primary ID
      changes = %{
        "reviews" => [
          %{"_id" => "uniq-insideId", "review" => "changed-something", "type" => 95},
          ]
        }
      updated_cs = Demo.changeset(doc, changes)
      Repo.update!(updated_cs)
      updated_doc = Repo.get!(Demo, main_id)
      assert updated_doc.reviews == 2
    end

  end

end
