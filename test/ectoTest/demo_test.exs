defmodule EctoTest.DemoTest do
  use EctoTest.DataCase
  alias EctoTest.Demo
  import Ecto.Query

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

  @simple_entry %{
    _id: "simpleID",
    name: "simple_entry",
    info: %{
      days: %{week: [1, 2, 4]},
      feeds: %{ids: ["123", "abc", "xyz"], on: true}
      }
  }

  @valid_map_entry %{
    _id: "#{Ecto.UUID.generate}",
    name: "ecto_test1",
    info: %{
      days: %{week: [1, 2, 4]},
      feeds: %{ids: ["123", "abc", "xyz"], on: true}
      },
    reviews: [
      %{_id: "uniq-insideId", review: "something", type: 1},
      %{_id: "uniq-insideId2", review: "needs more", type: 2}
      ]
    }

  @bad_review_type_entry %{
    _id: "#{Ecto.UUID.generate}",
    name: "ecto_test1",
    info: %{
      days: %{week: [1, 2, 4]},
      feeds: %{ids: ["123", "abc", "xyz"], on: true}
      },
    reviews: [
      %{_id: "uniq-insideId", review: "something", type: "string"},
      %{_id: "uniq-insideId2", review: "needs more", type: "string2"}
      ]
    }

  describe "Embeded CRUD" do
    test "cannot create an empty changeset" do
      cs = Demo.changeset(%Demo{}, %{})
      assert %Ecto.Changeset{
        valid?: false,
        errors: [info: {"can't be blank", [validation: :required]},
              name: {"can't be blank", [validation: :required]}]
      } = cs
    end

    test "embeded filed required" do
      cs = Demo.changeset(%Demo{}, %{name: "matt", _id: "1234asdf"})
      assert cs.errors == [info: {"can't be blank", [validation: :required]}]
      assert cs.valid? == false
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
      changes = %{
        info: %{
          days: %{week: [1, 2, 3, 4]},
          feeds: %{ids: ["123", "456"], on: false}
          },
        }
      updated_cs = Demo.changeset(doc, changes)
      Repo.update!(updated_cs)
      updated_doc = Repo.get!(Demo, main_id)
      assert updated_doc.info ==
        %InfoSchema{
          days: %DaysConfig{week: [1, 2, 3, 4]},
          feeds: %FeedsConfig{ids: ["123", "456"], on: false}
        }
    end

    test "Update a Doc -- Validate All Fields -- embeds_one" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      assert true == cs.valid?
      main_doc = Repo.insert!(cs)
      main_id = main_doc._id
      doc = Repo.get!(Demo, main_id)
      changes = %{
        info: %{
          feeds: %{ids: ["123", "456"], on: false}
          },
        }
      updated_cs = Demo.changeset(doc, changes)
      assert updated_cs.valid? == false
      assert updated_cs.changes.info.errors == [days: {"can't be blank", [validation: :required]}]
      catch_error Repo.update!(updated_cs)
    end

    test "Update a Doc -- Production way?? -- embeds_one" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      assert true == cs.valid?
      main_doc = Repo.insert!(cs)
      main_id = main_doc._id
      doc = Repo.get!(Demo, main_id)
      %{days: days, feeds: _feeds} = Map.from_struct(doc.info)
      changes = %{
        info: %{
          days: Map.from_struct(days),
          feeds: %{ids: ["123", "456"], on: false}
        }
      }
      updated_cs = Demo.changeset(doc, changes)
      Repo.update!(updated_cs)
      updated_doc = Repo.get!(Demo, main_id)
      assert updated_doc.info ==
        %InfoSchema{
          days: %DaysConfig{week: [1, 2, 4]},
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
          %{"_id" => "uniq-insideId2", "review" => "needs more", "type" => 2}
          ]
        }
      updated_cs = Demo.changeset(doc, changes)
      Repo.update!(updated_cs)
      updated_doc = Repo.get!(Demo, main_id)
      assert updated_doc.reviews == [
        %ReviewsSchema{_id: "uniq-insideId", review: "changed-something", type: 95},
        %ReviewsSchema{_id: "uniq-insideId2", review: "needs more", type: 2}
        ]
    end

    test "Update a Doc with More Stuff -- embeds_many" do
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
          %{"_id" => "uniq-insideId2", "review" => "needs more", "type" => 2},
          %{"_id" => "uniq-insideId3", "review" => "third Item", "type" => 45}
          ]
        }
      updated_cs = Demo.changeset(doc, changes)
      Repo.update!(updated_cs)
      updated_doc = Repo.get!(Demo, main_id)
      assert updated_doc.reviews == [
        %ReviewsSchema{_id: "uniq-insideId", review: "changed-something", type: 95},
        %ReviewsSchema{_id: "uniq-insideId2", review: "needs more", type: 2},
        %ReviewsSchema{_id: "uniq-insideId3", review: "third Item", type: 45}
        ]
    end

    test "or_where test" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      Repo.insert!(cs)
      cs2 = Demo.changeset(%Demo{}, @simple_entry)
      Repo.insert!(cs2)
      cs3 = Demo.changeset(%Demo{}, %{
        _id: "22",
        name: "ecto_test1",
        info: %{
          days: %{week: [1, 2, 4]},
          feeds: %{ids: ["123", "abc", "xyz"], on: true}
          }
      })
      Repo.insert!(cs3)
      all = Repo.all(Demo)
      assert length(all) == 3
      query2 =
        from a in Demo,
        where: (a._id == "simpleID") or (a._id == "22"),
        select: a

      assert length(Repo.all(query2)) == 2

      ##TODO NOT READY IN MONGO_ECTO BRANCH
      # query =
      #   from a in Demo,
      #   where: fragment([_id: "simpleID"]),
      #   or_where: fragment([_id: "22"]),
      #   select: a
      # #
      # assert length(Repo.all(query)) == 2
    end

    test "Mongo Command" do
      Repo.delete_all(Demo) # clear DB
      cs = Demo.changeset(%Demo{}, @valid_map_entry)
      Repo.insert!(cs)
      cs2 = Demo.changeset(%Demo{}, @simple_entry)
      Repo.insert!(cs2)
      cs3 = Demo.changeset(%Demo{}, %{
        _id: "22",
        name: "ecto_test1",
        info: %{
          days: %{week: [1, 2, 4]},
          feeds: %{ids: ["123", "abc", "xyz"], on: true}
          }
      })
      Repo.insert!(cs3)
      x = Mongo.Ecto.command(Repo, find: "ecto", filter: [_id: ["$in": ["22", "simpleID"]]])
      assert length(x["cursor"]["firstBatch"]) == 2
      y = Mongo.Ecto.command(Repo, find: "ecto", filter: ["$or": [[_id: "22"], [_id: "simpleID"]]])
      assert y["cursor"]["firstBatch"] ==
         [
          %{"_id" => "22",
            "info" => %{"days" => %{"week" => [1, 2, 4]},
                        "feeds" => %{"ids" => ["123", "abc", "xyz"], "on" => true}},
            "name" => "ecto_test1"},
          %{"_id" => "simpleID",
            "info" => %{"days" => %{"week" => [1, 2, 4]},
                        "feeds" => %{"ids" => ["123", "abc", "xyz"], "on" => true}},
            "name" => "simple_entry"}
          ]

    end


  end

end
