<script>
export default {
  props: {
    value: {
      type: String,
      required: true,
      default: '',
    },
    label: {
      type: String,
      required: true,
      default: '',
    },
    inputId: {
      type: String,
      required: true,
      default: 'commit-message-edit',
    },
  },
};
</script>

<template>
  <li>
    <div class="commit-message-editor">
      <div class="commit-message-label">
        <label class="col-form-label" for="commit-message">
          <strong>{{ label }}</strong>
        </label>
        <slot name="header"></slot>
      </div>
      <textarea
        :id="inputId"
        :value="value"
        class="form-control js-commit-message js-gfm-input"
        required="required"
        rows="14"
        name="Commit message"
        @input="$emit('input', $event.target.value)"
      ></textarea>
      <slot name="checkbox"></slot>
    </div>
  </li>
</template>
