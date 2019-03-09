self.addEventListener("push", function(event) {
  var json = event.data.json();
  self.registration.showNotification(json.title, {
    body: json.body,
    icon: json.icon,
    actions: json.actions
  });
});

self.addEventListener('notificationclick', function(event) {
  var order_id = null;
  event.notification.close();

  if (event.action.match(/^review-purchase/) || event.action.match(/^review-sale/)) {
    order_id = event.action.split("-")[2];
    clients.openWindow("/marketplace/orders/" + order_id);
  }
}, false);
