'use strict';
module.exports = function(app) {
  var runQueue = require('../controllers/nodeposh-api-controller');

app.route('/runqueue')
    .post(runQueue.run_a_script);

app.route('/runlog')
    .post(runQueue.post_a_run)
    .get(runQueue.check_script_runs);
    //.delete(runQueue.delete_runlog);
};
