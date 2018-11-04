import './style.scss';
import Truncate from './truncate';

document.addEventListener('turbolinks:load', () => {
  Truncate.init();
});
