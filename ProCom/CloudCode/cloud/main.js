
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

			var newConvo = new Convo();
			newConvo.set("incode", "jsTesterIncode2");
			var relation = newConvo.relation("users");
			relation.add(user);
			newConvo.save();

			response.success("Success");
		},
		error: function() {
			response.error("Failure");
		}
	});

});


