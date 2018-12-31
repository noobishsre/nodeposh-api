'use strict';
var mongoose = require('mongoose');
var Schema = mongoose.Schema;


var RunlogSchema = new Schema({
  script_name: {
    type: String,
    required: 'Kindly enter the name of script ran'
  },
  host_name: {
    type: String,
    required: 'Kindly enter the hostname'
  },
  Runtime_date: {
    type: Date,
    default: Date.now
  }
});
module.exports = mongoose.model('runlog', RunlogSchema);

var APICallSchema = new Schema({
    hostname: {
      type: String,
      required: 'Kindly enter hostname'
    }
});
module.exports = mongoose.model('runqueue', APICallSchema);
