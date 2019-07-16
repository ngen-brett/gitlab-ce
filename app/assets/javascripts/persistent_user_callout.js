import axios from './lib/utils/axios_utils';
import { __ } from './locale';
import Flash from './flash';

const DEFERRED_LINK_CLASS = 'deferred-link';

export default class PersistentUserCallout {
  constructor(container) {
    const { dismissEndpoint, featureId, deferLinks } = container.dataset;
    this.container = container;
    this.dismissEndpoint = dismissEndpoint;
    this.featureId = featureId;
    this.deferLinks = typeof deferLinks !== 'undefined';

    this.init();
  }

  init() {
    const closeButton = this.container.querySelector('.js-close');
    closeButton.addEventListener('click', event => this.dismiss(event));

    if (this.deferLinks) {
      this.container.querySelector('.deferred-link').addEventListener('click', event => {
        event.preventDefault();

        this.dismiss(event);
      });
    }
  }

  dismiss(event) {
    event.preventDefault();

    axios
      .post(this.dismissEndpoint, {
        feature_name: this.featureId,
      })
      .then(() => {
        this.container.remove();

        if (this.deferLinks && event.target.classList.contains(DEFERRED_LINK_CLASS)) {
          const { href, target } = event.target;
          window.open(href, target);
        }
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
