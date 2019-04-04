<script>
import { SYSTEM_NOTE } from '../constants';

const NoteableNote = () => import('./noteable_note.vue');
const PlaceholderNote = () => import('../../vue_shared/components/notes/placeholder_note.vue');
const PlaceholderSystemNote = () =>
  import('../../vue_shared/components/notes/placeholder_system_note.vue');
const SystemNote = () => import('~/vue_shared/components/notes/system_note.vue');
const ToggleRepliesWidget = () => import('./toggle_replies_widget.vue');

export default {
  name: 'DiscussionNotes',
  components: {
    NoteableNote,
    PlaceholderNote,
    PlaceholderSystemNote,
    SystemNote,
    ToggleRepliesWidget,
  },
  props: {
    canReply: {
      type: Boolean,
      required: true,
    },
    commit: {
      type: Object,
      required: false,
      default: null,
    },
    discussion: {
      type: Object,
      required: true,
    },
    firstNote: {
      type: Object,
      required: true,
    },
    hasReplies: {
      type: Boolean,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: false,
      default: '',
    },
    isExpanded: {
      type: Boolean,
      required: true,
    },
    line: {
      type: Object,
      required: false,
      default: null,
    },
    replies: {
      type: Array,
      required: false,
      default: () => [],
    },
    shouldGroupReplies: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    componentName(note) {
      if (note.isPlaceholderNote) {
        if (note.placeholderType === SYSTEM_NOTE) {
          return PlaceholderSystemNote;
        }

        return PlaceholderNote;
      }

      if (note.system) {
        return SystemNote;
      }

      return NoteableNote;
    },
    componentData(note) {
      return note.isPlaceholderNote ? note.notes[0] : note;
    },
  },
};
</script>

<template>
  <ul class="notes">
    <template v-if="shouldGroupReplies">
      <component
        :is="componentName(firstNote)"
        :note="componentData(firstNote)"
        :line="line"
        :commit="commit"
        :help-page-path="helpPagePath"
        :show-reply-button="canReply"
        @handle-delete-note="$emit('handleDeleteNote')"
        @start-replying="$emit('startReplying')"
      >
        <note-edited-text
          v-if="discussion.resolved"
          slot="discussion-resolved-text"
          :edited-at="discussion.resolved_at"
          :edited-by="discussion.resolved_by"
          :action-text="resolvedText"
          class-name="discussion-headline-light js-discussion-headline discussion-resolved-text"
        />
        <slot slot="avatar-badge" name="avatar-badge"></slot>
      </component>
      <toggle-replies-widget
        v-if="hasReplies"
        :collapsed="!isExpanded"
        :replies="replies"
        @toggle="$emit('toggleDiscussion')"
      />
      <template v-if="isExpanded">
        <component
          :is="componentName(note)"
          v-for="note in replies"
          :key="note.id"
          :note="componentData(note)"
          :help-page-path="helpPagePath"
          :line="line"
          @handle-delete-note="$emit('deleteNote')"
        />
      </template>
    </template>
    <template v-else>
      <component
        :is="componentName(note)"
        v-for="(note, index) in discussion.notes"
        :key="note.id"
        :note="componentData(note)"
        :help-page-path="helpPagePath"
        :line="diffLine"
        @handle-delete-note="deleteNoteHandler"
      >
        <slot v-if="index === 0" slot="avatar-badge" name="avatar-badge"></slot>
      </component>
    </template>
  </ul>
</template>
