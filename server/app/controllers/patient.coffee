express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'
Promise = require 'bluebird'
async = Promise.coroutine
moment = require 'moment'

User = mongoose.model 'User'
Talk = mongoose.model 'Talk'

module.exports = (app) ->
  app.use '/patient', router

router.get '/signup', (req, res, next) ->
  res.render 'patient_signup',
    title: '用户注册'
    msg: req.flash 'msg'

router.post '/signup', async (req, res, next) ->
  try
    patient = new User
      username: req.body.username
      password: req.body.password
      type: 'patient'
    yield patient.saveAsync()
    req.session.user = patient
    req.flash 'msg', 'SIGNUPOK'
    res.redirect '/patient/index'
  catch e
    req.flash 'msg', 'SIGNUPERR'
    res.redirect '/patient/signup'

router.get '/signin', (req, res, next) ->
  res.render 'patient_signin',
    title: '用户登录'
    msg: req.flash 'msg'

router.post '/signin', async (req, res, next) ->
  try
    patient = yield User.findOne
      username: req.body.username
      password: req.body.password
    .execAsync()
    throw new Error("Invalid account") unless patient?
    req.session.user = patient
    req.flash 'msg', 'SIGNINOK'
    res.redirect '/patient/index'
  catch e
    req.flash 'msg', 'SIGNINERR'
    res.redirect '/patient/signin'

router.get '/index', async (req, res, next) ->
  try
    patient = yield User.findById(req.session.user._id).populate('doctor').execAsync()
    doctor = patient.doctor
    if !doctor?
      req.flash 'msg', 'SELECTDOCTOR'
      return res.redirect '/patient/select'
    talks = yield Talk.find().or([{from: patient}, {to: patient}]).sort('-createdAt').populate('from').populate('to').execAsync()
    return res.render 'patient_panel',
      title: '咨询面板'
      patient: patient
      doctor: doctor
      talks: talks
      moment: moment
      msg: req.flash 'msg'
  catch e
    next e

router.post '/index', async (req, res, next) ->
  try
    patient = yield User.findById(req.session.user._id).populate('doctor').execAsync()
    doctor = patient.doctor
    talk = new Talk
      from: patient
      to: doctor
      temperature: req.body.temperature
      pressure: req.body.pressure
      content: req.body.content
      createdAt: Date.now()
    yield talk.saveAsync()
    req.flash 'msg', 'SENDTALKOK'
    res.redirect '/patient/index'
  catch e
    req.flash 'msg', 'SENDTALKERR'
    res.redirect '/patient/index'

router.get '/select', async (req, res, next) ->
  try
    doctors = yield User.find
      type: 'doctor'
    .execAsync()
    res.render 'select_doctor',
      title: '选择医生'
      user: req.session.user
      doctors: doctors
      msg: req.flash 'msg'
  catch e
    next e

router.get '/select/:id', async (req, res, next) ->
  try
    doctor = yield User.findById req.params.id
    user = yield User.findById req.session.user._id
    user.doctor = doctor
    doctor.patients.push user
    yield user.saveAsync()
    yield doctor.saveAsync()
    req.session.user = user
    req.flash 'msg', 'SELECTDOCTOROK'
    res.redirect '/patient/index'
  catch e
    next e
