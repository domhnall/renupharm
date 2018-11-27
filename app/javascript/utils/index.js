import './style.scss';
import Truncate from './truncate';
import Progress from './progress';

document.addEventListener('turbolinks:load', () => {
  Truncate.init();
  Progress.init();
});
