<script>
/**
 * Render environments table.
 */
import { GlLoadingIcon } from '@gitlab/ui';
import environmentItem from './environment_item.vue';

export default {
  components: {
    environmentItem,
    GlLoadingIcon,
  },

  props: {
    environments: {
      type: Array,
      required: true,
      default: () => [],
    },

    canReadEnvironment: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    folderUrl(model) {
      return `${window.location.pathname}/folders/${model.folderName}`;
    },
    shouldRenderFolderContent(env) {
      return env.isFolder && env.isOpen && env.children && env.children.length > 0;
    },
    sortEnvironments(environments) {
      return Array.from(environments).sort((x, y) => {
        if (x.isFolder && y.isFolder) {
          x.folderName.localeCompare(y.folderName);
        }

        if (x.isFolder) {
          return -1;
        }

        if (y.isFolder) {
          return 1;
        }

        if (!x.last_deployment && !y.last_deployment) {
          return x.name.localeCompare(y.name);
        }

        if (!x.last_deployment) {
          return 1;
        }

        if (!y.last_deployment) {
          return -1;
        }

        return x.last_deployment.created_at - y.last_deployment.created_at;
      });
    },
  },
};
</script>
<template>
  <div class="ci-table" role="grid">
    <div class="gl-responsive-table-row table-row-header" role="row">
      <div class="table-section section-15 environments-name" role="columnheader">
        {{ s__('Environments|Environment') }}
      </div>
      <div class="table-section section-10 environments-deploy" role="columnheader">
        {{ s__('Environments|Deployment') }}
      </div>
      <div class="table-section section-15 environments-build" role="columnheader">
        {{ s__('Environments|Job') }}
      </div>
      <div class="table-section section-20 environments-commit" role="columnheader">
        {{ s__('Environments|Commit') }}
      </div>
      <div class="table-section section-10 environments-date" role="columnheader">
        {{ s__('Environments|Updated') }}
      </div>
    </div>
    <template v-for="(model, i) in sortEnvironments(environments)" :model="model">
      <div
        is="environment-item"
        :key="`environment-item-${i}`"
        :model="model"
        :can-read-environment="canReadEnvironment"
      />

      <template v-if="shouldRenderFolderContent(model)">
        <div v-if="model.isLoadingFolderContent" :key="`loading-item-${i}`">
          <gl-loading-icon :size="2" class="prepend-top-16" />
        </div>

        <template v-else>
          <div
            is="environment-item"
            v-for="(children, index) in sortEnvironments(model.children)"
            :key="`env-item-${i}-${index}`"
            :model="children"
            :can-read-environment="canReadEnvironment"
          />

          <div :key="`sub-div-${i}`">
            <div class="text-center prepend-top-10">
              <a :href="folderUrl(model)" class="btn btn-default">{{
                s__('Environments|Show all')
              }}</a>
            </div>
          </div>
        </template>
      </template>
    </template>
  </div>
</template>
