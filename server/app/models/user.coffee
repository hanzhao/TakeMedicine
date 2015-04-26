mongoose = require 'mongoose'
Schema = mongoose.Schema

UserSchema = new Schema
  username:
    type: String
    index:
      unique: true
  password: String
  type: String
  patients: [
    type: Schema.Types.ObjectId
    ref: 'User'
  ]
  doctor:
    type: Schema.Types.ObjectId
    ref: 'User'

mongoose.model 'User', UserSchema
