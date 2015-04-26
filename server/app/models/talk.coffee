mongoose = require 'mongoose'
Schema = mongoose.Schema

TalkSchema = new Schema
  from:
    type: Schema.Types.ObjectId
    ref: 'User'
  to:
    type: Schema.Types.ObjectId
    ref: 'User'
  temperature: String
  pressure: String
  content: String
  createdAt: Date

mongoose.model 'Talk', TalkSchema
