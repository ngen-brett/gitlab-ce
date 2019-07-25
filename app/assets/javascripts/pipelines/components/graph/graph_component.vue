<script>
import { GlLoadingIcon } from '@gitlab/ui';
import StageColumnComponent from './stage_column_component.vue';
import GraphMixin from '../../mixins/graph_component_mixin';
import { debounceByAnimationFrame } from '~/lib/utils/common_utils';

let debouncedResize;

export default {
  components: {
    StageColumnComponent,
    GlLoadingIcon,
  },
  mixins: [GraphMixin],
  data() {
    return {
      leftPadding: 0,
    };
  },
  beforeDestroy() {
    window.removeEventListener('resize', debouncedResize);
  },
  created() {
    this.onResize();
    debouncedResize = debounceByAnimationFrame(this.onResize);
    window.addEventListener('resize', debouncedResize);
  },
  methods: {
    onResize(event) {
      const width = event ? event.target.innerWidth : window.innerWidth;
      if (width < 1330) this.leftPadding = 0;
      else this.leftPadding = (width - 1330) / 2 + 70;
    },
  },
};
</script>
<template>
  <div class="build-content middle-block js-pipeline-graph">
    <div
      class="pipeline-visualization pipeline-graph pipeline-tab-content"
      :style="{ paddingLeft: `${leftPadding}px` }"
    >
      <div v-if="isLoading" class="m-auto"><gl-loading-icon :size="3" /></div>

      <ul v-if="!isLoading" class="stage-column-list">
        <stage-column-component
          v-for="(stage, index) in graph"
          :key="stage.name"
          :title="capitalizeStageName(stage.name)"
          :groups="stage.groups"
          :stage-connector-class="stageConnectorClass(index, stage)"
          :is-first-column="isFirstColumn(index)"
          :action="stage.status.action"
          @refreshPipelineGraph="refreshPipelineGraph"
        />
      </ul>
    </div>
  </div>
</template>
