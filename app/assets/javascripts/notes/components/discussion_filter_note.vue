<script>
import $ from 'jquery';
import { GlButton } from '@gitlab/ui';

import { spriteIcon } from '~/lib/utils/common_utils';

import { DISCUSSION_FILTER_TYPES } from '../constants';

export default {
  filterTypes: DISCUSSION_FILTER_TYPES,
  components: {
    GlButton,
  },
  computed: {
    iconHtml() {
      return spriteIcon('comment');
    },
  },
  methods: {
    selectFilter(value) {
      const $dropdown = $('.js-discussion-filter-container .dropdown-menu');
      const $dropdownButton = $dropdown.find('#discussion-filter-dropdown');

      // Since toggling filter from dropdown
      // does a lot of additional changes (eg; state updates, filtering store etc)
      // it is better to directly trigger it from dropdown element
      // instead of duplicating effort here.
      // See discussion_filter.vue's `selectFilter` method to learn more.
      $dropdown.find(`li[data-filter-type="${value}"] button`).click();
      $dropdownButton.dropdown('toggle');
    },
  },
};
</script>

<template>
  <li class="timeline-entry note note-wrapper discussion-filter-note js-discussion-filter-note">
    <div class="timeline-icon" v-html="iconHtml"></div>
    <div class="timeline-content">
      <div
        v-html="
          __(`You're only seeing <b>other activity</b> in the feed. To add a comment, switch to
      one of the following options.`)
        "
      ></div>
      <div class="discussion-filter-actions mt-2">
        <gl-button type="button" variant="default" @click="selectFilter($options.filterTypes.ALL)">
          {{ __('Show all activity') }}
        </gl-button>
        <gl-button
          type="button"
          variant="default"
          @click="selectFilter($options.filterTypes.COMMENTS)"
        >
          {{ __('Show comments only') }}
        </gl-button>
      </div>
    </div>
  </li>
</template>
