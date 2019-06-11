<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  props: {
    descriptionHtml: {
      type: String,
      required: true,
    },
  },
  computed: {
    linksInDescription() {
      const el = document.createElement();
      el.innerHTML = this.descriptionHtml;
      return [...el.querySelectorAll('a')].map(a => a.href);
    },
    zoomHref() {
      // TODO: possibly limit to links ending with [js]\/[\d]{9}
      const zoomRegex = /^https:\/\/([\w\d-]+\.)?zoom\.us\/.+/;
      return this.linksInDescription.reduce((finalLink, currentLink) => {
        if (zoomRegex.test(currentLink)) {
          finalLink = currentLink;
        }
        return finalLink;
      }, '');
    },
  },
}
</script>

<template>
  <div
    v-if="zoomHref"
    class="border-bottom mb-3"
    style="margin-top: -8px"
  >
    <gl-link
      v-if="zoomHref"
      :href="zoomHref"
      class="btn btn-inverted btn-secondary btn-sm text-dark mb-3"
    >
      <!-- TODO: icon component -->
      <svg
        width="16"
        height="16"
        viewBox="0 0 16 16"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M1.44914 3.3335C0.648801 3.3335 0 3.9823 0 4.78263V9.76855C0 11.3692 1.2976 12.6668 2.89827 12.6668H9.8842C10.6845 12.6668 11.3333 12.018 11.3333 11.2177V6.23177C11.3333 4.6311 10.0357 3.3335 8.43506 3.3335H1.44914ZM16 4.64251V11.3575C16 11.9023 15.3819 12.2171 14.9412 11.8966L12.8824 10.3993C12.5374 10.1484 12.3333 9.74762 12.3333 9.32103V6.67897C12.3333 6.25238 12.5374 5.85156 12.8824 5.60065L14.9412 4.10336C15.3819 3.78289 16 4.09766 16 4.64251Z"
          fill="#0E71EB"
        />
      </svg>
      <span class="vertical-align-top">{{ __('Join Zoom meeting') }}</span>
    </gl-link>
  </div>
</template>
