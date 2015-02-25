
var Convo = Parse.Object.extend("Convo");
var User = Parse.Object.extend("User");

// Add an existing user to an existing conversation
// @params: 'userId' and 'convoId' 
Parse.Cloud.define("addUserToConvo", function(request, response) {

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