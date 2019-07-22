import Vue from 'vue';
import canaryCalloutMixin from 'ee_else_ce/environments/mixins/canary_callout_mixin';
import environmentsComponent from './components/environments_app.vue';
import { parseBoolean } from '../lib/utils/common_utils';
import Translate from '../vue_shared/translate';

Vue.use(Translate);

export default () =>
  new Vue({
    el: '#environments-list-view',
    components: {
      environmentsComponent,
    },
    mixins: [canaryCalloutMixin],
    data() {
      const domEl = document.querySelector(this.$options.el)

      let environmentsData = domEl.dataset;
      environmentsData.projectId = domEl.getAttribute('data-project-id');

      return {
        endpoint: environmentsData.environmentsDataEndpoint,
        projectId: environmentsData.projectId,
        newEnvironmentPath: environmentsData.newEnvironmentPath,
        helpPagePath: environmentsData.helpPagePath,
        deployBoardsHelpPath: environmentsData.deployBoardsHelpPath,
        cssContainerClass: environmentsData.cssClass,
        canCreateEnvironment: parseBoolean(environmentsData.canCreateEnvironment),
        canReadEnvironment: parseBoolean(environmentsData.canReadEnvironment),
      };
    },
    render(createElement) {
      return createElement('environments-component', {
        props: {
          endpoint: this.endpoint,
          projectId: this.projectId,
          newEnvironmentPath: this.newEnvironmentPath,
          helpPagePath: this.helpPagePath,
          deployBoardsHelpPath: this.deployBoardsHelpPath,
          cssContainerClass: this.cssContainerClass,
          canCreateEnvironment: this.canCreateEnvironment,
          canReadEnvironment: this.canReadEnvironment,
          ...this.canaryCalloutProps,
        },
      });
    },
  });
