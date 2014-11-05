process.env.NODE_ENV = process.env.NODE_ENV || 'development'

dbConfig = require('./knexfile')
express = require('express')
knex = require('knex')(dbConfig[process.env.NODE_ENV])
bookshelf = require('bookshelf')(knex)
bodyParser = require('body-parser')
app = express()

Score = bookshelf.Model.extend({
  tableName: 'scores'
  hasTimestamps: true
  })

corsMiddleware =  (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*');
  next()

app.use(corsMiddleware)
app.use(bodyParser.json())

app.route('/scores')
  .all( (req, res, next) ->
    res.set('Content-Type', 'application/json')
    next()
  )
  .get((req, res, next) ->
    Score.collection().query( (qb) ->
      qb.orderBy('score', 'desc').limit(20)
    ).fetch().then( (collection) ->
      res.json(collection)
    , (error) ->
      res.status(500)
      res.end()
    )
  )
  .post( (req, res, next) ->
    Score.forge(req.body).save().then( (score) ->
      res.json(score)
    , (error) ->
      res.status(400)
      res.end()
    )
  )

app.listen(3000)
