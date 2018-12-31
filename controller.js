'use strict';

const shell = require('node-powershell'); //need to install module
var mongoose = require('mongoose'),
    RunLog = mongoose.model('runlog'),
    RunQueue = mongoose.model('runqueue');

exports.check_script_runs = function(req, res) {
    RunLog.find({}, function(err, runlog) {
        if (err)
            res.send(err);
            res.json(runlog);
    });
};

exports.post_a_run = function(req,res) {
    var run_post = new RunLog(req.body);
    run_post.save(function(err, runlog) {
        if(err)
            res.send(err);
            res.json(runlog);
    });
};

exports.run_a_script = function(req, res) {
    var host_name = req.body.hostname;
    let ps = new shell({
        executionPolicy: 'Bypass',
        noProfile: true
    });

    ps.addCommand('powershell c:\\git\\nodeposh-api\\pwsh\\Start-PwshTest.ps1 -ComputerName ' + host_name)
    ps.invoke()
    .then(output => {
    console.log(output);
    ps.dispose();
    })
    .catch(err => {
    console.log(err);
    ps.dispose();
    });

    var new_run = new RunQueue(req.body);
    new_run.save(function(err, runqueue) {
        if(err)
            res.send(err);
            res.json(runqueue);
    });
};

/*
exports.read_a_runlog = function(req, res) {
    Task.findById(req.params.runId, function(err, task) {
        if (err)
            res.send(err);
            res.json(task);
    });
};


exports.update_a_task = function(req, res) {
  Task.findOneAndUpdate({_id: req.params.taskId}, req.body, {new: true}, function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
};


exports.delete_a_task = function(req, res) {


  Task.remove({
    _id: req.params.taskId
  }, function(err, task) {
    if (err)
      res.send(err);
    res.json({ message: 'Task successfully deleted' });
  });
};
*/
