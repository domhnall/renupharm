import './style.scss';
import './account.scss';
import './profile.scss';
import './marketplace/style.scss';
import './marketplace/listing.scss';
import './marketplace/cart.scss';
import './marketplace/orders.scss';
import PushNotifications from './push_notifications';

PushNotifications.init();
document.addEventListener('turbolinks:load', () => {
  const preferences_section = document.getElementById('notification_config');

  if(preferences_section){
    const form = preferences_section.querySelector("form.edit_notification_config");
    form.addEventListener("change", function(e){
      form.submit();
    });
  }
});

