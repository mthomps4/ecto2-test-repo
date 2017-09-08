## Ecto Tests
#### Confirm or Deny all with tests

Primary Key Issue

*Does everything save to Mongo as expected*

- [x] Set Primary Key to False for embeds_one (not needed)
- [x] Test to confirm


Confirm Embedded Validation
- [x] How to: embedded changesets
- [x] Confirm best practice to validate embedded schema
- [x] Tests to confirm

Updates
- [x] Update embedded schema
- [x] Tests for embeds_one and embeds_many schema
- [x] Tests to show passing results -- with Mongo

Queries
- [ ] Ecto Query using `or_where`
- [ ] `or_where` with embedded schema

```elixir
query =
  from doc in collection
  where: ...stuff
  or_where: other_stuff
  select: doc
```



Test Notes:
`embeds_one` Schema is a on_replace: :delete
Replaces everything with new thing... make sure it's all there.

`embeds_many` seems to need both an ID and all items to build a changeset
