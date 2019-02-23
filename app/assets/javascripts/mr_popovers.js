import Vue from 'vue';
import Vuex from 'vuex';
import MRPopover from './vue_shared/components/mr_popover/mr_popover.vue';
import createMRPopoversStore from './vuex_shared/modules/mr_popovers';

let renderedPopover;
let renderFn;

const handleUserPopoverMouseOut = ({ target }) => {
  target.removeEventListener('mouseleave', handleUserPopoverMouseOut);

  if (renderFn) {
    clearTimeout(renderFn);
  }
  if (renderedPopover) {
    renderedPopover.$destroy();
    renderedPopover = null;
  }
};

/**
 * Adds a UserPopover component to the body, hands over as much data as the target element has in data attributes.
 * loads based on data-user-id more data about a user from the API and sets it on the popover
 */
const handleMRPopoverMount = store => ({ target }) => {
  // Add listener to actually remove it again
  target.addEventListener('mouseleave', handleUserPopoverMouseOut);

  const projectID = target.attributes['data-project'].value;
  const mergeRequestIID = target.attributes['data-iid'].value;
  const mergeRequest = {};

  renderFn = setTimeout(() => {
    const MRPopoverComponent = Vue.extend(MRPopover);
    renderedPopover = new MRPopoverComponent({
      propsData: {
        target,
        projectID,
        mergeRequestIID,
        mergeRequest,
      },
      store,
    });

    renderedPopover.$mount();
  }, 200); // 200ms delay so not every mouseover triggers Popover + API Call
};

export default elements => {
  Vue.use(Vuex);

  const store = new Vuex.Store(createMRPopoversStore());
  // TODO: figure out proper default selector
  const userLinks = elements || [...document.querySelectorAll('.gfm-merge_request')];

  userLinks.forEach(el => {
    el.addEventListener('mouseenter', handleMRPopoverMount(store));
  });
};
