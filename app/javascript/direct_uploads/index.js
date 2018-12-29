import './style.scss';
import DirectUploads from './direct_uploads';
import RemoveUploads from './remove_uploads';
import * as ActiveStorage from 'activestorage';

ActiveStorage.start();
DirectUploads.init();
document.addEventListener('turbolinks:load', () => {
  RemoveUploads.init();
});
