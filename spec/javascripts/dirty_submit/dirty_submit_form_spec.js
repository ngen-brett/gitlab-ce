import DirtySubmitForm from '~/dirty_submit/dirty_submit_form';
import { setInput, createForm } from './helper';
import setTimeoutPromise from '../helpers/set_timeout_promise_helper';

describe('DirtySubmitForm', () => {
  it('disables submit until there are changes', done => {
    const { form, input, submit } = createForm();
    const originalValue = input.value;

    new DirtySubmitForm(form); // eslint-disable-line no-new

    return setTimeoutPromise()
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(() => setInput(input, `${originalValue} changes`))
      .then(() => {
        expect(submit.disabled).toBe(false);
      })
      .then(() => setInput(input, originalValue))
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(done)
      .catch(done.fail);
  });

  it('disables submit until there are changes when initializing with a falsy value', done => {
    const { form, input, submit } = createForm();
    input.value = '';
    const originalValue = input.value;

    new DirtySubmitForm(form); // eslint-disable-line no-new

    return setTimeoutPromise()
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(() => setInput(input, `${originalValue} changes`))
      .then(() => {
        expect(submit.disabled).toBe(false);
      })
      .then(() => setInput(input, originalValue))
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(done)
      .catch(done.fail);
  });

  it('disables submit until there are changes for radio inputs', done => {
    const { form, input, submit } = createForm('radio');

    new DirtySubmitForm(form); // eslint-disable-line no-new

    return setTimeoutPromise()
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(() => setInput(input))
      .then(() => {
        expect(submit.disabled).toBe(false);
      })
      .then(() => setInput(input))
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(done)
      .catch(done.fail);
  });

  it('disables submit until there are changes for checkbox inputs', done => {
    const { form, input, submit } = createForm('checkbox');

    new DirtySubmitForm(form); // eslint-disable-line no-new

    return setTimeoutPromise()
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(() => setInput(input))
      .then(() => {
        expect(submit.disabled).toBe(false);
      })
      .then(() => setInput(input))
      .then(() => {
        expect(submit.disabled).toBe(true);
      })
      .then(done)
      .catch(done.fail);
  });
});
