
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
	response.success("Hello world!");
});

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

Parse.Cloud.define("userConvos", function(request, response) {

	// Get the User by its objectId
	var qUser = new Parse.Query("User");
	qUser.equalTo("objectId", request.params.objectId);

	var qConvo = new Parse.Query("Convo");

	qUser.first({
		success: function(user) {
			convoIds = user.get("convoIds");
			response.success(convoIds);
		},
		error: function() {
			response.error("No convos found for this user");
		}
	});
});