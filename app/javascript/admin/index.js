import init_charts from './charts';
import init_comments from './comments';

document.addEventListener("admin_dashboard:init", function() {
  init_charts();
});

document.addEventListener("turbolinks:load", function() {
  init_comments();
});
