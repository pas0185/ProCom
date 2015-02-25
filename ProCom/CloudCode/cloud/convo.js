
var Convo = Parse.Object.extend("Convo");
var User = Parse.Object.extend("User");

// Add an existing user to an existing conversation
// @params: 'userId' and 'convoId' 
Parse.Cloud.define("addUserToConvo", function(request, response) {

	// Get the User
	var queryUser = new Parse.Query("User");
	var queryConvo = new Parse.Query("Convo");

	queryUser.get(request.params.userId, {
		success: function(user) {
			// Successfully found the user
			queryConvo.get(request.params.convoId, {
				success: function(convo) {
					// Successfully found the convo
					var relation = convo.relation("users");
					relation.add(user);
					convo.save(null, {
						success: function() {
							response.success("Successfully added user to convo");
						},
						error: function(error) {
							response.error("Failed to add user to convo: " + error);
						}
					});
				},
				error: function(convo, error) {
					response.error("Failed to retrieve convo: " + error);

				}
			});
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});

// Create a new conversation
// Parse.cloud.define("createNewConvo" function(request, response) {

// });

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