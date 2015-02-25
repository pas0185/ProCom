
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

require('cloud/convo.js')
require('cloud/user.js')
require('cloud/group.js')
require('cloud/blurb.js')


Parse.Cloud.define("hello", function(request, response) {
	response.success("Hello world!");
});
