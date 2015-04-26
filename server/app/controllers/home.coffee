express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'

module.exports = (app) ->
  app.use '/', router

router.get '/', (req, res, next) ->
  res.render 'index',
    title: '改吃药了'
