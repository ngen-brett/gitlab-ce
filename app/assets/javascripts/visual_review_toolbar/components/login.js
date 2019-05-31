/* global document, window */

import buttonClearStyles from './utils';

 import {
   clearNote,
   note,
   postError,
 } from './note';

 import { addCommentForm } from './wrapper';

const login = `
  <div>
    <label for='gitlab-token' class='gitlab-label'>Enter your <a class='gitlab-link' href="https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html">personal access token</a></label>
    <input class='gitlab-input' type='password' id='gitlab-token' name='gitlab-token'>
    ${note}
  </div>
  <div class='gitlab-checkbox-wrapper'>
    <input type="checkbox" id="remember_token" name="remember_token" value="remember">
    <label for="remember_token" class='gitlab-checkbox-label'>Remember me</label>
  </div>
  <div class='gitlab-button-wrapper'>
    <button class='gitlab-button-wide gitlab-button gitlab-button-success' style='${buttonClearStyles}' type='button' id='gitlab-login'> Submit </button>
  </div>
`;

const storeToken = (token, state) => {
  const { localStorage } = window;
  const rememberMe = document.getElementById('remember_token').checked;

  // All the browsers we support have localStorage, so let's silently fail
  // and go on with the rest of the functionality.
  if (rememberMe) {
    try {
      localStorage.setItem('token', token);
    } finally {
      state.token = token;
    }
  }
}

const authorizeUser = (state) => {
  // Clear any old errors
  clearNote('gitlab-token');

  const token = document.getElementById('gitlab-token').value;

  if (!token) {
    postError('Please enter your token.', 'gitlab-token');
    return;
  }

  storeToken(token, state);
  addCommentForm();
}

export { authorizeUser, login }
