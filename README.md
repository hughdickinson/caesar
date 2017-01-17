# README

Caesar is an evolution of the Nero codebase, which is made more generic. In essence, Caesar receives classifications from the event stream (a Lambda script sends them to Caesars HTTP API). 

For each classification, it runs zero or more extractors defined in the workflow to generate "extracts". These extracts specify information summarized out of the full classification.

Whenever extracts change, Caesar will then run zero or more reducers defined in the workflow. Each reducer receives all the extracts, merged into one hash per classification. The task of the reducer is to aggregate results from multiple classifications into key-value pairs, where values are simple data types: integers or booleans. The output of each reducer is stored in the database as a `Reduction`.

Whenever a reduction changes, Caesar will then run zero or more rules defined in the workflow. Each rule is a boolean statement that can look at values produced by reducers (by key), compare. Rules support logic clauses like `and` / `or` / `not`. When the rule evaluates to `true`, all of the effects associated with that rule will be performed. For instance, an effect might be to retire a subject.

To make this more concrete, an example would be a survey-task workflow where:

* An extractor emits key-value pairs like `lion=1` when the user tagged a lion in the image.
* A reducer combines multiple classifications by adding up the lion counts, emitting `lion=5, coyote=1`
* A rule then checks `lion > 4`, which returns true, and therefore Caesar retires the image.

## Development

Prepare the Docker containers:

```
docker-compose build
docker-compose run app bin/rails db:setup
docker-compose run -e RAILS_ENV=test app bin/rails db:create
```

Run tests with:

```
docker-compose run -e RAILS_ENV=test app bin/rspec
```
