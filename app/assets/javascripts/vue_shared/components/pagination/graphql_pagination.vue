<script>
import { GlButton } from '@gitlab/ui';
import { PREV, NEXT } from '~/vue_shared/components/pagination/constants';

/**
 * Pagination Component for graphql API
 */
export default {
  name: 'GraphqlPaginationComponent',
  components: {
    GlButton,
  },
  labels: {
    prev: PREV,
    next: NEXT,
  },
  props: {
    hasNextPage: {
      required: true,
      type: Boolean,
    },
    hasPreviousPage: {
      required: true,
      type: Boolean,
    },
  },
};
</script>
<template>
  <div class="gl-pagination">
    <ul class="pagination justify-content-center">
      <li class="page-item">
        <gl-button
          class="page-link"
          @click="$emit('previousClicked')"
          :disabled="!hasPreviousPage"
        >{{ $options.labels.prev }}</gl-button>
      </li>

      <li class="page-item">
        <gl-button
          class="page-link"
          @click="$emit('nextClicked')"
          :disabled="!hasNextPage"
        >{{ $options.labels.next }}</gl-button>
      </li>
    </ul>
  </div>
</template>
