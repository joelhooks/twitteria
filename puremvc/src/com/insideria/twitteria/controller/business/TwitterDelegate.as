package com.insideria.twitteria.controller.business {
	
	import com.insideria.twitteria.ApplicationFacade;
	import com.insideria.twitteria.model.UserProxy;
	
	import mx.rpc.IResponder;
	
	import twitter.api.Twitter;
	import twitter.api.data.TwitterStatus;
	import twitter.api.data.TwitterUser;
	import twitter.api.events.TwitterEvent;
	
	public class TwitterDelegate {
		
		private var responder:IResponder;
		private var twitterService:Twitter;
		
		private var useDummyData:Boolean = true;
		private var username:String;
		private var password:String;
		
		public function TwitterDelegate(responder:IResponder) {
			trace("creating TwitterDelegate with useDummyData: " + useDummyData);
			this.responder = responder;
			var userProxy:UserProxy = ApplicationFacade.getInstance().retrieveProxy(UserProxy.NAME) as UserProxy;
			username = userProxy.username;
			password = userProxy.password;
			twitterService = new Twitter();
			twitterService.setAuthenticationCredentials(username, password);
			twitterService.addEventListener(TwitterEvent.ON_FRIENDS_TIMELINE_RESULT, friendsTimelineLoaded);
			twitterService.addEventListener(TwitterEvent.ON_SET_STATUS, statusSet);
		}
		
		public function loadTimeline():void {
			trace("loading timeline for " + username);
			if (useDummyData) {
				var te:TwitterEvent = new TwitterEvent(TwitterEvent.ON_FRIENDS_TIMELINE_RESULT);
				te.data = getDummyData();
				friendsTimelineLoaded(te);
			} else {
				twitterService.loadFriendsTimeline(username);
			}
		}
		
		public function setStatus(statusText:String):void {
			trace("setting status to '" + statusText + "'");
			if (useDummyData) {
				statusSet(null);
			} else {
				twitterService.setStatus(statusText);
			}
		}
		
		private function friendsTimelineLoaded(te:TwitterEvent):void {
			responder.result(te.data as Array);
		}
		
		private function statusSet(te:TwitterEvent):void {
			responder.result(null);
		}
		
		private function getDummyData():Array {
			var i:int;
			var statusObj:Object;
			var status:TwitterStatus;
			var dd:Array = [];
			var user:TwitterUser = new TwitterUser()
			user.name = "Dummy User";
			user.profileImageUrl = "https://static.twitter.com/images/default_profile_normal.png"
			for (;i <= 10; i++) {
				statusObj = { 
					id:i,
					created_at:"Sun Sep 21 22:15:04 +0000 2008",
					text: "Dummy message #" + i 
				}
				status = new TwitterStatus(statusObj, user);
				dd.push(status);
			}
			return dd;
		}
		

	}
}