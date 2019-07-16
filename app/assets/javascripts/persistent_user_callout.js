import axios from './lib/utils/axios_utils';
import { __ } from './locale';
import Flash from './flash';

export default class PersistentUserCallout {
  constructor(container) {
    const { dismissEndpoint, featureId, deferLinks } = container.dataset;
    this.container = container;
    this.dismissEndpoint = dismissEndpoint;
    this.featureId = featureId;
    this.deferLinks = deferLinks;
    debugger;

    this.init();
  }

  init() {
    const closeButton = this.container.querySelector('.js-close');
    closeButton.addEventListener('click', event => this.dismiss(event));

    if (this.deferLinks) {
      this.container.querySelector('.deferred-link').addEventListener('click', event => {
        const linkHref = event.target.attributes.href;
        event.preventDefault();

        this.dismiss(event, function() {
          window.location.href = linkHref;
        });
      });
    }
  }

  dismiss(event, callback) {
    event.preventDefault();

    axios
      .post(this.dismissEndpoint, {
        feature_name: this.featureId,
      })
      .then(() => {
        this.container.remove();

        if (callback) callback();
      })
      .catch(() => {
        Flash(__('An error occurred while dismissing the alert. Refresh the page and try again.'));
      });
  }

  static factory(container) {
    if (!container) {
      return undefined;
    }

    return new PersistentUserCallout(container);
  }
}
