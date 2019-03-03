const PushNotifications = {
  init: function(){
    const self = this;
    if(!("Notification" in window)){ return; }

    if(Notification.permission === "granted"){
      self.register();
    }else if(Notification.permission !== 'denied'){
      Notification.requestPermission(function (permission) {
        if (permission === "granted") {
          self.register();
        }
     });
    }
  },

  register: function(){
    let serviceWorker = null;

    if (!navigator.serviceWorker) { return; }
    navigator.serviceWorker.register('/serviceworker.js')
    .then(function(registration) {
      return navigator.serviceWorker.ready;
    })
    .then((sw) => {
      serviceWorker = sw;
      return serviceWorker.pushManager.getSubscription();
    })
    .then((subscription) => {
      // Short-circuit if we already have a subscription
      if(subscription){ return; }
      return serviceWorker.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: window.vapidPublicKey
      });
    })
    .then((new_subscription) => {
      // Don't post to server if we haven't created a new subscription
      if(!new_subscription){ return; }
      let token = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
      return fetch("/web_push_subscriptions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": token
        },
        body: JSON.stringify({web_push_subscription: {
          subscription: new_subscription.toJSON()
        }})
      });
    })
    .catch((error) => {
      console.log(error);
    });
  }
};

export default PushNotifications;
