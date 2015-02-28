

// Get the full group hierarchy for a given user
// @param: 'userId'

// 		{"userId":"kRaibtYs3r"}

Parse.Cloud.define("getGroupsAndConvosForUser", function(request, response) {
	// Group.js
	var User = Parse.Object.extend("User");
	var Group = Parse.Object.extend("Group");
	var Convo = Parse.Object.extend("Convo");

	var queryUser = new Parse.Query("User");
	var queryConvo = new Parse.Query("Convo");
	var queryGroup = new Parse.Query("Group");

	queryUser.get(request.params.userId, {
		success: function(user) {
			// Successfully found user, get all conversations subscribed to
			queryConvo.equalTo("users", user);
			queryConvo.include('groupId');
			queryConvo.find({
				success: function(convos) {
					var groups = [];

					for (var i = 0; i < convos.length; i++) {
						var convo = convos[i];
						// Get the parent group of each Convo
						groups.push(JSON.stringify(convo['groupId']));
					}
					response.success(groups);
				},
				error: function(convos, error) {
					response.error("Failed to retrieve user's convos: " + error);
				}
			})
		},
		error: function(user, error) {
			response.error("Failed to retrieve user: " + error);
		}
	});
});


//adding a convo to a group
// Parse.Cloud.define("addConvotoGroup", function(request,response){
// 	var queryConvo
// });
