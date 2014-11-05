
exports.up = (knex, Promise) ->
  knex.schema.createTable('scores', (table) ->
    table.increments()
    table.string('name')
    table.integer('score')
    table.timestamps()
  )

exports.down = (knex, Promise) ->
  knex.schema.dropTable('scores')
