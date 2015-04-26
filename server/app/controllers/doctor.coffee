express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'
Promise = require 'bluebird'
async = Promise.coroutine
moment = require 'moment'

User = mongoose.model 'User'
Talk = mongoose.model 'Talk'

module.exports = (app) ->
  app.use '/doctor', router

router.get '/signup', (req, res, next) ->
  res.render 'doctor_signup',
    title: '用户注册'

router.post '/signup', async (req, res, next) ->
  try
    doctor = new User
      username: req.body.username
      password: req.body.password
      type: 'doctor'
    yield doctor.saveAsync()
    req.session.user = doctor
    res.redirect '/doctor/index?msg=SIGNUPOK'
  catch e
    res.redirect '/doctor/signup?msg=SIGNUPERR'

router.get '/signin', (req, res, next) ->
  res.render 'doctor_signin',
    title: '用户登录'

router.post '/signin', async (req, res, next) ->
  try
    doctor = yield User.findOne
      username: req.body.username
      password: req.body.password
    .execAsync()
    throw new Error("Invalid account") unless doctor?
    req.session.user = doctor
    res.redirect '/doctor/index?msg=SIGNINOK'
  catch e
    res.redirect '/doctor/signin?msg=SIGNINERR'

router.get '/index', async (req, res, next) ->
  try
    patients = yield User.find
      doctor: req.session.user
    .execAsync()
    res.render 'select_patient',
      title: '选择病人'
      patients: patients
  catch e
    next e

router.get '/select/:id', async (req, res, next) ->
  try
    patient = yield User.findById(req.params.id).populate('doctor').execAsync()
    doctor = patient.doctor
    talks = yield Talk.find().or([{from: patient}, {to: patient}]).sort('-createdAt').populate('from').populate('to').execAsync()
    res.render 'doctor_panel',
      title: '咨询面板'
      patient: patient
      doctor: doctor
      talks: talks
      moment: moment
  catch e
    next e

router.post '/select/:id', async (req, res, next) ->
  try
    patient = yield User.findById(req.params.id).populate('doctor').execAsync()
    doctor = patient.doctor
    talk = new Talk
      from: doctor
      to: patient
      content: req.body.content
      createdAt: Date.now()
    yield talk.saveAsync()
    res.redirect "/doctor/select/#{patient._id}?msg=SENDTALKOK"
  catch e
    res.redirect "/doctor/select/#{patient._id}?msg=SENDTALKERR"
