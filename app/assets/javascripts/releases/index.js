import Vue from 'vue';
import App from './components/app.vue';
import createStore from './store';

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-releases-page');

  return new Vue({
    el: element,
    store: createStore(),
    components: {
      App,
    },
    render(createElement) {
      return createElement('app', {
        props: {
          endpoint: element.dataset.endpoint,
        },
      });
    },
  });
});
