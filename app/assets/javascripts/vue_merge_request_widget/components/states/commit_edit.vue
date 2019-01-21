<script>
export default {
  props: {
    value: {
      type: String,
      required: true,
      default: '',
    },
    squash: {
      type: Boolean,
      required: false,
    },
  },
};
</script>

<template>
  <li>
    <div v-if="squash"><strong>Commit message</strong></div>
    <div class="prepend-top-default commit-message-editor">
      <div class="form-group clearfix">
        <label class="col-form-label" for="commit-message">
          <strong>Squash commit message</strong>
        </label>
        <div class="commit-message-container">
          <textarea
            id="commit-message"
            :value="value"
            @input="$emit('input', $event.target.value)"
            class="form-control js-commit-message"
            required="required"
            rows="14"
            name="Commit message"
          ></textarea>
        </div>
      </div>
    </div>
  </li>
</template>
