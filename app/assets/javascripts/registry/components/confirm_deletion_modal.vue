<script>
import { mapState, mapActions } from 'vuex';
import _ from 'underscore';
import { GlModal } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';

export default {
  name: 'ConfirmRegistryDeletionModal',
  components: {
    GlModal,
  },
  computed: {
    ...mapState({
      data: state => state.confirmDeletionModal,
    }),
    isImage() {
      return this.data.type === 'image';
    },
    modalTitle() {
      return this.isImage ? __('Delete image') : __('Delete repository');
    },
    modalActionText() {
      return this.isImage ? __('Delete image and tags') : __('Delete');
    },
    modalText() {
      const text = this.isImage
        ? __(
            'You are about to delete the image <b>%{title}</b>. This will delete the image and all tags pointing to this image.',
          )
        : __(
            'You are about to delete repository <b>%{title}</b>. Once you confirm, this repository will be permanently deleted.',
          );
      return sprintf(text, { title: this.data.title });
    },
  },
  methods: {
    ...mapActions(['resetDeletionModal', 'deleteItem']),
    onOk() {
      try {
        this.deleteItem(this.data.item);
        this.data.onSuccess();
      } catch (e) {
        this.data.onError(e);
      }
    },
  },
};
</script>
<template>
  <gl-modal
    :visible="data.isVisible"
    :title="modalTitle"
    modal-id="registry-confirm-deletion-modal"
    :ok-title="modalActionText"
    ok-variant="danger"
    @ok="onOk"
    @hide="resetDeletionModal"
  >
    <p v-html="modalText"></p>
  </gl-modal>
</template>
