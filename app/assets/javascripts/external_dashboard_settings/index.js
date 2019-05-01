import Vue from 'vue';
import ExternalDashboardForm from './components/form.vue';

export default () => {
  const el = document.querySelector('.js-external-dashboard-form');

  return new Vue({
    el,
    render(createElement) {
      return createElement(ExternalDashboardForm, {
        props: {
          ...el.dataset,
        },
      });
    },
  });
};
