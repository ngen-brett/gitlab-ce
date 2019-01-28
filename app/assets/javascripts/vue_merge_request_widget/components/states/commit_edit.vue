<script>
export default {
  props: {
    value: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    inputId: {
      type: String,
      required: true,
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
