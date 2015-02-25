require('cloud/blurb.js')
require('cloud/userConvo.js')
require('cloud/userGroups.js')

Parse.Cloud.define("testRelation", function(request, response) {

	var Convo = Parse.Object.extend("Convo");

	// Get the User by its objectId
	var qUser = new Parse.Query("User");
	qUser.equalTo("objectId", request.params.objectId);

	qUser.first({
		success: function(user) {
});