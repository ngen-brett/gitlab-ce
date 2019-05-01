<script>
import { GlFormGroup, GlFormInput } from '@gitlab/ui';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
  },
};
</script>

<template>
  <form>
    <gl-form-group
      :label="__('Full dashboard URL')"
      :description="__('Enter the URL of the dashboard you want to link to')"
    >
      <gl-form-input placeholder="https://mydashboards.com" />
    </gl-form-group>
  </form>
</template>
