## Ecto Tests
#### Confirm or Deny all with tests

Primary Key Issue

*Does everything save to Mongo as expected*

- [ ] Set Primary Key to False for embeds_one (not needed)
- [ ] Test to confirm


Confirm Embedded Validation
- [ ] How to: embedded changesets
- [ ] Confirm best practice to validate embedded schema
- [ ] Tests to confirm

Updates
- [ ] Update embedded schema
- [ ] Tests for embeds_one and embeds_many schema
- [ ] Tests to show passing results -- with Mongo

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
