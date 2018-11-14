import DirtySubmitForm from '~/dirty_submit/dirty_submit_form';
import setTimeoutPromiseHelper from '../helpers/set_timeout_promise_helper';

export function setInput(input, value) {
  const target = input;
  const { type } = input;
  let eventType;

  if (type === 'text') {
    target.value = value;
    eventType = 'input';
  } else if (/(radio|checkbox)/.test(type)) {
    target.checked = !target.checked;
    eventType = 'change';
  }

  target.dispatchEvent(
    new Event(eventType, {
      bubbles: true,
    }),
  );

  return setTimeoutPromiseHelper(DirtySubmitForm.THROTTLE_DURATION);
}

export function createForm(type = 'text') {
  const form = document.createElement('form');
  form.innerHTML = `
    <input type="${type}" name="${type}" class="js-input"/>
    <button type="submit" class="js-dirty-submit"></button>
  `;

  const input = form.querySelector('.js-input');
  const submit = form.querySelector('.js-dirty-submit');

  return {
    form,
    input,
    submit,
  };
}
