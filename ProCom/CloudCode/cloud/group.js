// Group.js

var User = Parse.Object.extend("User");
var Group = Parse.Object.extend("Group");
var Convo = Parse.Object.extend("Convo");

// Get the full group hierarchy for a given user
// @param: 'userId'

// 		{"userId":"kRaibtYs3r"}

Parse.Cloud.define("getGroupsForUser", function(request, response) {

	var queryUser = new Parse.Query("User");
	var queryConvo = new Parse.Query("Convo");

	queryUser.get(request.params.userId, {
		success: function(user) {
			// Successfully found user, get all conversations subscribed to
			
			var queryConvo = new Parse.Query("Convo");
			var relation = 
			queryConvo.find({

			})
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});