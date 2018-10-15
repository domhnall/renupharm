import './style.scss';
import Survey from './survey';

document.addEventListener('turbolinks:load', () => {
  Survey.init_survey_results();
});
