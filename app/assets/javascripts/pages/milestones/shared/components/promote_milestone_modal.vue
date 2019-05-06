<script>
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import GlModal from '~/vue_shared/components/gl_modal.vue';
import promoteMilestoneModalMixin from 'ee_else_ce/pages/milestones/shared/mixins/promote_milestone_modal';
import { s__, sprintf } from '~/locale';
import { isEE } from '~/lib/utils/common_utils';
import { visitUrl } from '~/lib/utils/url_utility';
import eventHub from '../event_hub';

export default {
  components: {
    GlModal,
  },
  mixins: [promoteMilestoneModalMixin],
  props: {
    milestoneTitle: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: true,
    },
    groupName: {
      type: String,
      required: true,
    },
  },
  computed: {
    title() {
      return sprintf(s__('Milestones|Promote %{milestoneTitle} to group milestone?'), {
        milestoneTitle: this.milestoneTitle,
      });
    },
    isEE() {
      return isEE();
    },
  },
  methods: {
    onSubmit() {
      eventHub.$emit('promoteMilestoneModal.requestStarted', this.url);
      return axios
        .post(this.url, { params: { format: 'json' } })
        .then(response => {
          eventHub.$emit('promoteMilestoneModal.requestFinished', {
            milestoneUrl: this.url,
            successful: true,
          });
          visitUrl(response.data.url);
        })
        .catch(error => {
          eventHub.$emit('promoteMilestoneModal.requestFinished', {
            milestoneUrl: this.url,
            successful: false,
          });
          createFlash(error);
        });
    },
  },
};
</script>
<template>
  <gl-modal
    id="promote-milestone-modal"
    :footer-primary-button-text="s__('Milestones|Promote Milestone')"
    footer-primary-button-variant="warning"
    @submit="onSubmit"
  >
    <template slot="title">
      {{ title }}
    </template>
    <div v-if="isEE" v-html="text"></div>
    <template v-else>
      {{ text }}
    </template>
  </gl-modal>
</template>
