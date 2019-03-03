self.addEventListener("push", (event) => {
  const json = event.data.json();
  self.registration.showNotification(json.title, {
    body: json.body,
    icon: json.icon
  });

  // event.waitUntil(self.registration.showNotification(title, { body, icon, tag }));
});
