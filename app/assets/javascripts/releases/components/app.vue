<script>
import { mapState, mapActions } from 'vuex';
import { GlLoadingIcon } from '@gitlab-org/gitlab-ui';

export default {
  name: 'ReleasesApp',
  components: {
    GlLoadingIcon,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    }
  },
  computed: {
    ...mapState([
      'isLoading',
      'data',
      'hasError',
    ]),
  },
  created() {
    this.setEndpoint(this.endpoint);
    this.fetchReleases();
  },
  methods: {
    ...mapActions([
      'setEndpoint',
      'fetchReleases'
    ]),
  }
};
</script>
<template>
  <div>
    <gl-loading-icon
      v-if="isLoading"
      :size="2"
      class="js-loading qa-loading-animation prepend-top-20"
    />
    <div
      v-else-if="!releases.length"
      class="js-empty-state"
    >
      {{ __('No releases published yet') }}
    </div>
    <div
      v-else
      class="js-success-state"
    >
      <release-block
        v-for="release in releases"
        :key="release.tag_name"
        :name="release.name"
        :tag="release.tag_name"
        :commit="release.commit"
        :description="release.description_html"
        :author="release.author"
        :created-at="release.created_at"
        :assets-count="release.assets.count"
        :sources="release.assets.sources"
        :links="release.assets.links"
      />
    </div>
  </div>
</template>
