<script>
/* eslint-disable promise/catch-or-return */

import $ from 'jquery';
import _ from 'underscore';
import Autosave from '~/autosave';
import Autosize from 'autosize';
import { __ } from '~/locale';
import { stripHtml } from '~/lib/utils/text_utility';
import Flash from '../../../flash';
import GLForm from '../../../gl_form';
import { CopyAsGFM } from '~/behaviors/markdown/copy_as_gfm';
import markdownHeader from './header.vue';
import markdownToolbar from './toolbar.vue';
import icon from '../icon.vue';
import Suggestions from '~/vue_shared/components/markdown/suggestions.vue';
import { updateText } from '~/lib/utils/text_markdown';

export default {
  components: {
    markdownHeader,
    markdownToolbar,
    icon,
    Suggestions,
  },
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
    markdownPreviewPath: {
      type: String,
      required: false,
      default: '',
    },
    markdownDocsPath: {
      type: String,
      required: true,
    },
    markdownVersion: {
      type: Number,
      required: false,
      default: 0,
    },
    addSpacingClasses: {
      type: Boolean,
      required: false,
      default: true,
    },
    quickActionsDocsPath: {
      type: String,
      required: false,
      default: '',
    },
    canAttachFile: {
      type: Boolean,
      required: false,
      default: true,
    },
    enableAutocomplete: {
      type: Boolean,
      required: false,
      default: true,
    },
    line: {
      type: Object,
      required: false,
      default: null,
    },
    note: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    canSuggest: {
      type: Boolean,
      required: false,
      default: false,
    },
    helpPagePath: {
      type: String,
      required: false,
      default: '',
    },
    editable: {
      type: Boolean,
      required: false,
      default: true,
    },
    autosaveKey: {
      type: Array,
      required: false,
      default: () => [],
    },
    textareaId: {
      type: String,
      required: false,
      default: '',
    },
    textareaName: {
      type: String,
      required: false,
      default: '',
    },
    textareaClass: {
      type: String,
      required: false,
      default: '',
    },
    textareaSupportsQuickActions: {
      type: Boolean,
      required: false,
      default: false,
    },
    textareaLabel: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      mode: 'markdown',
      glForm: null,
      autosave: null,
      currentValue: this.value,
      renderedLoading: false,
      renderedValue: null,
      rendered: '',
      referencedCommands: '',
      referencedUsers: '',
      hasSuggestion: false,
    };
  },
  computed: {
    renderedOutdated() {
      return this.currentValue !== this.renderedValue;
    },
    needsMarkdownRender() {
      return this.renderedOutdated && this.mode === 'preview';
    },
    shouldShowReferencedUsers() {
      const referencedUsersThreshold = 10;
      return this.referencedUsers.length >= referencedUsersThreshold;
    },
    lineContent() {
      const [firstSuggestion] = this.suggestions;
      if (firstSuggestion) {
        return firstSuggestion.from_content;
      }

      if (this.line) {
        const { rich_text: richText, text } = this.line;

        if (text) {
          return text;
        }

        return _.unescape(stripHtml(richText).replace(/\n/g, ''));
      }

      return '';
    },
    lineNumber() {
      let lineNumber;
      if (this.line) {
        const { new_line: newLine, old_line: oldLine } = this.line;
        lineNumber = newLine || oldLine;
      }
      return lineNumber;
    },
    suggestions() {
      return this.note.suggestions || [];
    },
    lineType() {
      return this.line ? this.line.type : '';
    },
  },
  watch: {
    mode() {
      this.$nextTick().then(() => {
        this.focus();

        switch (this.mode) {
          case 'markdown':
            this.autosizeTextarea();
            break;
          case 'preview':
            this.renderPreviewGFM();
            break;
          default:
            break;
        }
      });
    },
    needsMarkdownRender() {
      if (this.needsMarkdownRender) {
        this.$nextTick().then(() => this.renderMarkdown());
      }
    },
    rendered() {
      if (this.mode === 'preview') {
        this.$nextTick().then(this.renderPreviewGFM);
      }
    },
    value() {
      this.setCurrentValue(this.value, { emitEvent: false });
    },
    currentValue() {
      if (this.autosave) {
        this.$nextTick().then(() => this.autosave.save());
      }

      if (this.mode === 'markdown') {
        this.$nextTick().then(this.autosizeTextarea);
      }
    },
  },
  mounted() {
    this.glForm = this.createGLForm();

    if (this.autosaveKey.length) {
      this.autosave = new Autosave($(this.$refs.textarea), this.autosaveKey);
    }

    Autosize(this.$refs.textarea);
    this.autosizeTextarea();
  },
  beforeDestroy() {
    this.glForm.destroy();

    if (this.autosave) {
      this.autosave.reset();
      this.autosave.dispose();
    }

    Autosize.destroy(this.$refs.textarea);
  },
  methods: {
    createGLForm() {
      return new GLForm($(this.$refs.glForm), {
        emojis: this.enableAutocomplete,
        members: this.enableAutocomplete,
        issues: this.enableAutocomplete,
        mergeRequests: this.enableAutocomplete,
        epics: this.enableAutocomplete,
        milestones: this.enableAutocomplete,
        labels: this.enableAutocomplete,
        snippets: this.enableAutocomplete,
      });
    },

    setCurrentValue(newValue, { emitEvent = true } = {}) {
      if (newValue === this.currentValue) return;

      this.currentValue = newValue;

      if (emitEvent) {
        this.$emit('input', this.currentValue);
      }
    },

    quoteNode(node) {
      const blockquoteEl = document.createElement('blockquote');
      blockquoteEl.appendChild(node.cloneNode(true));

      const markdown = CopyAsGFM.nodeToGFM(blockquoteEl);

      const current = this.currentValue.trim();
      const separator = current.length ? '\n\n' : '';
      this.setCurrentValue(`${current}${separator}${markdown}\n\n`);

      this.$nextTick().then(this.focus);
    },

    blur() {
      if (this.mode === 'markdown') {
        this.$refs.textarea.blur();
      }
    },

    focus() {
      if (this.mode === 'markdown') {
        this.$refs.textarea.focus();
      }
    },

    renderMarkdown() {
      if (!this.renderedOutdated || this.renderedLoading) return;

      const text = this.currentValue;

      if (text.length) {
        this.renderedLoading = true;
        this.$http
          .post(this.versionedRenderPath(), { text })
          .then(resp => resp.json())
          .then(data => this.updateRendered(text, data))
          .catch(() => new Flash(__('Error rendering markdown')));
      } else {
        this.updateRendered(text);
      }
    },

    updateRendered(text, data = {}) {
      this.rendered = data.body || '';

      if (data.references) {
        this.referencedCommands = data.references.commands;
        this.referencedUsers = data.references.users;
        this.hasSuggestion = data.references.suggestions && data.references.suggestions.length;
      }

      this.renderedLoading = false;
      this.renderedValue = text;
    },

    renderPreviewGFM() {
      $(this.$refs.markdownPreview).renderGFM();
    },

    autosizeTextarea() {
      Autosize.update(this.$refs.textarea);
    },

    versionedRenderPath() {
      const { markdownPreviewPath, markdownVersion } = this;
      return `${markdownPreviewPath}${
        markdownPreviewPath.indexOf('?') === -1 ? '?' : '&'
      }markdown_version=${markdownVersion}`;
    },

    toolbarButtonClicked(button) {
      updateText({
        textArea: this.$refs.textarea,
        tag: button.tag,
        blockTag: button.tagBlock,
        wrap: !button.prepend,
        select: button.tagSelect,
        cursorOffset: button.cursorOffset,
        tagContent: button.tagContent,
      });
    },

    triggerEditPrevious() {
      if (!this.currentValue.length) this.$emit('edit-previous');
    },

    triggerSave() {
      this.$emit('save');
    },

    triggerCancel() {
      this.$emit('cancel');
    },

    onTextareaInput() {
      this.setCurrentValue(this.$refs.textarea.value);
    },
  },
};
</script>

<template>
  <div
    ref="glForm"
    :class="{ 'prepend-top-default append-bottom-default': addSpacingClasses }"
    class="md-area js-vue-markdown-field"
  >
    <markdown-header
      :line-content="lineContent"
      :can-suggest="canSuggest"
      :mode="mode"
      @preview="mode = 'preview'"
      @markdown="mode = 'markdown'"
      @toolbar-button-clicked="toolbarButtonClicked"
    />
    <div v-show="mode === 'markdown'" class="md-write-holder">
      <div :class="{ 'div-dropzone-wrapper': true, 'zen-backdrop': mode === 'markdown' }">
        <textarea
          :id="textareaId"
          ref="textarea"
          placeholder="Write a comment or drag your files here…"
          :value="currentValue"
          :name="textareaName"
          :class="['note-textarea markdown-area js-gfm-input js-vue-textarea', textareaClass]"
          :data-supports-quick-actions="textareaSupportsQuickActions"
          :aria-label="textareaLabel"
          :disabled="!editable"
          @keydown.up="triggerEditPrevious"
          @keydown.meta.enter="triggerSave"
          @keydown.ctrl.enter="triggerSave"
          @keydown.esc="triggerCancel"
          @input="onTextareaInput"
        >
        </textarea>

        <a class="zen-control zen-control-leave js-zen-leave" href="#" aria-label="Exit zen mode">
          <icon :size="32" name="screen-normal" />
        </a>
        <markdown-toolbar
          :markdown-docs-path="markdownDocsPath"
          :quick-actions-docs-path="quickActionsDocsPath"
          :can-attach-file="canAttachFile"
        />
      </div>
    </div>

    <div v-show="mode === 'preview'" class="js-vue-md-preview md-preview-holder">
      <span v-if="renderedOutdated">
        {{ __('Loading…') }}
      </span>
      <span v-else-if="rendered.length === 0">
        Nothing to preview
      </span>
      <template v-else-if="hasSuggestion">
        <div ref="markdownPreview" class="md md-preview">
          <suggestions
            v-if="hasSuggestion"
            :note-html="rendered"
            :from-line="lineNumber"
            :from-content="lineContent"
            :line-type="lineType"
            :disabled="true"
            :suggestions="suggestions"
            :help-page-path="helpPagePath"
          />
        </div>
      </template>
      <template v-else>
        <div ref="markdownPreview" class="md md-preview" v-html="rendered"></div>
      </template>
    </div>

    <template v-if="mode === 'preview' && !renderedOutdated">
      <div v-if="referencedCommands" class="referenced-commands" v-html="referencedCommands"></div>
      <div v-if="shouldShowReferencedUsers" class="referenced-users">
        <span>
          <i class="fa fa-exclamation-triangle" aria-hidden="true"></i> You are about to add
          <strong>
            <span class="js-referenced-users-count">{{ referencedUsers.length }}</span>
          </strong>
          people to the discussion. Proceed with caution.
        </span>
      </div>
    </template>
  </div>
</template>
