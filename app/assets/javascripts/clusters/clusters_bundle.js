import Visibility from 'visibilityjs';
import Vue from 'vue';
import { s__, sprintf } from '../locale';
import Flash from '../flash';
import Poll from '../lib/utils/poll';
import initSettingsPanels from '../settings_panels';
import eventHub from './event_hub';
import {
  APPLICATION_INSTALLED,
  REQUEST_LOADING,
  REQUEST_SUCCESS,
  REQUEST_FAILURE,
} from './constants';
import ClustersService from './services/clusters_service';
import ClustersStore from './stores/clusters_store';
import applications from './components/applications.vue';

/**
 * Cluster page has 2 separate parts:
 * Toggle button and applications section
 *
 * - Polling status while creating or scheduled
 * - Update status area with the response result
 */

export default class Clusters {
  constructor() {
    const {
      statusPath,
      installHelmPath,
      installIngressPath,
      installRunnerPath,
      clusterStatus,
      clusterStatusReason,
      helpPath,
    } = document.querySelector('.js-edit-cluster-form').dataset;

    this.store = new ClustersStore();
    this.store.setHelpPath(helpPath);
    this.store.updateStatus(clusterStatus);
    this.store.updateStatusReason(clusterStatusReason);
    this.service = new ClustersService({
      endpoint: statusPath,
      installHelmEndpoint: installHelmPath,
      installIngressEndpoint: installIngressPath,
      installRunnerEndpoint: installRunnerPath,
    });

    this.toggle = this.toggle.bind(this);
    this.installApplication = this.installApplication.bind(this);

    this.toggleButton = document.querySelector('.js-toggle-cluster');
    this.toggleInput = document.querySelector('.js-toggle-input');
    this.errorContainer = document.querySelector('.js-cluster-error');
    this.successContainer = document.querySelector('.js-cluster-success');
    this.creatingContainer = document.querySelector('.js-cluster-creating');
    this.errorReasonContainer = this.errorContainer.querySelector('.js-error-reason');
    this.successApplicationContainer = document.querySelector('.js-cluster-application-notice');

    initSettingsPanels();
    this.initApplications();

    if (this.store.state.status !== 'created') {
      this.updateContainer(null, this.store.state.status, this.store.state.statusReason);
    }

    this.addListeners();
    if (statusPath) {
      this.initPolling();
    }
  }

  initApplications() {
    const store = this.store;
    const el = document.querySelector('#js-cluster-applications');

    this.applications = new Vue({
      el,
      components: {
        applications,
      },
      data() {
        return {
          state: store.state,
        };
      },
      render(createElement) {
        return createElement('applications', {
          props: {
            applications: this.state.applications,
            helpPath: this.state.helpPath,
          },
        });
      },
    });
  }

  addListeners() {
    this.toggleButton.addEventListener('click', this.toggle);
    eventHub.$on('installApplication', this.installApplication);
  }

  removeListeners() {
    this.toggleButton.removeEventListener('click', this.toggle);
    eventHub.$off('installApplication', this.installApplication);
  }

  initPolling() {
    this.poll = new Poll({
      resource: this.service,
      method: 'fetchData',
      successCallback: data => this.handleSuccess(data),
      errorCallback: () => Clusters.handleError(),
    });

    if (!Visibility.hidden()) {
      this.poll.makeRequest();
    } else {
      this.service.fetchData()
        .then(data => this.handleSuccess(data))
        .catch(() => Clusters.handleError());
    }

    Visibility.change(() => {
      if (!Visibility.hidden() && !this.destroyed) {
        this.poll.restart();
      } else {
        this.poll.stop();
      }
    });
  }

  static handleError() {
    Flash(s__('ClusterIntegration|Something went wrong on our end.'));
  }

  handleSuccess(data) {
    const prevStatus = this.store.state.status;
    const prevApplicationMap = Object.assign({}, this.store.state.applications);

    this.store.updateStateFromServer(data.data);

    this.checkForNewInstalls(prevApplicationMap, this.store.state.applications);
    this.updateContainer(prevStatus, this.store.state.status, this.store.state.statusReason);
  }

  toggle() {
    this.toggleButton.classList.toggle('checked');
    this.toggleInput.setAttribute('value', this.toggleButton.classList.contains('checked').toString());
  }

  hideAll() {
    this.errorContainer.classList.add('hidden');
    this.successContainer.classList.add('hidden');
    this.creatingContainer.classList.add('hidden');
  }

  checkForNewInstalls(prevApplicationMap, newApplicationMap) {
    const appTitles = Object.keys(newApplicationMap)
      .filter(appId => newApplicationMap[appId].status === APPLICATION_INSTALLED &&
        prevApplicationMap[appId].status !== APPLICATION_INSTALLED &&
        prevApplicationMap[appId].status !== null)
      .map(appId => newApplicationMap[appId].title);

    if (appTitles.length > 0) {
      this.successApplicationContainer.textContent = sprintf(s__('ClusterIntegration|%{appList} was successfully installed on your cluster'), {
        appList: appTitles.join(', '),
      });
      this.successApplicationContainer.classList.remove('hidden');
    } else {
      this.successApplicationContainer.classList.add('hidden');
    }
  }

  updateContainer(prevStatus, status, error) {
    this.hideAll();

    // We poll all the time but only want the `created` banner to show when newly created
    if (this.store.state.status !== 'created' || prevStatus !== this.store.state.status) {
      switch (status) {
        case 'created':
          this.successContainer.classList.remove('hidden');
          break;
        case 'errored':
          this.errorContainer.classList.remove('hidden');
          this.errorReasonContainer.textContent = error;
          break;
        case 'scheduled':
        case 'creating':
          this.creatingContainer.classList.remove('hidden');
          break;
        default:
          this.hideAll();
      }
    }
  }

  installApplication(appId) {
    this.store.updateAppProperty(appId, 'requestStatus', REQUEST_LOADING);
    this.store.updateAppProperty(appId, 'requestReason', null);

    this.service.installApplication(appId)
      .then(() => {
        this.store.updateAppProperty(appId, 'requestStatus', REQUEST_SUCCESS);
      })
      .catch(() => {
        this.store.updateAppProperty(appId, 'requestStatus', REQUEST_FAILURE);
        this.store.updateAppProperty(appId, 'requestReason', s__('ClusterIntegration|Request to begin installing failed'));
      });
  }

  destroy() {
    this.destroyed = true;

    this.removeListeners();

    if (this.poll) {
      this.poll.stop();
    }

    this.applications.$destroy();
  }
}
