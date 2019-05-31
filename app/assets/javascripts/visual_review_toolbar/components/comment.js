/* global document, window */

import buttonClearStyles from './utils';

import {
 clearNote,
 note,
 postError,
} from './note';

const comment = `
  <div>
    <textarea id='gitlab-comment' name='gitlab-comment' rows='3' placeholder='Enter your feedback or idea' class='gitlab-input'></textarea>
    ${note}
    <p class='gitlab-metadata-note'>Additional metadata will be included: browser, OS, current page, user agent, and viewport dimensions.</p>
  </div>
  <div class='gitlab-button-wrapper''>
    <button class='gitlab-button gitlab-button-secondary' style='${buttonClearStyles}' type='button' id='gitlab-logout-button'> Logout </button>
    <button class='gitlab-button gitlab-button-success' style='${buttonClearStyles}' type='button' id='gitlab-comment-button'> Send feedback </button>
  </div>
`;

const resetCommentBox = () => {
  const commentBox = document.getElementById('gitlab-comment');
  const commentButton = document.getElementById('gitlab-comment-button');

  commentButton.innerText = 'Send feedback';
  commentButton.classList.replace('gitlab-button-secondary', 'gitlab-button-success');
  commentButton.style.opacity = 1;

  commentBox.style.pointerEvents = 'auto';
  commentBox.style.color = 'rgba(0, 0, 0, 1)';
}

const resetCommentButton = () => {
  const commentBox = document.getElementById('gitlab-comment');
  const currentNote = document.getElementById('gitlab-validation-note');

  commentBox.value = '';
  currentNote.innerText = '';
  resetCommentBox();
}

const confirmAndClear = (mergeRequestId) => {
  const commentButton = document.getElementById('gitlab-comment-button');
  const currentNote = document.getElementById('gitlab-validation-note');

  commentButton.innerText = 'Feedback sent';
  currentNote.innerText = `Your comment was successfully posted to merge request #${mergeRequestId}`;

  setTimeout(resetCommentButton, 1000);
}

const setInProgressState = () => {
  const commentButton = document.getElementById('gitlab-comment-button');
  const commentBox = document.getElementById('gitlab-comment');

  commentButton.innerText = 'Sending feedback';
  commentButton.classList.replace('gitlab-button-success', 'gitlab-button-secondary');
  commentButton.style.opacity = 0.5;
  commentBox.style.color = 'rgba(223, 223, 223, 0.5)';
  commentBox.style.pointerEvents = 'none';
}

const postComment = ({
  href,
  platform,
  browser,
  userAgent,
  innerWidth,
  innerHeight,
  projectId,
  mergeRequestId,
  mrUrl,
  token
}) => {
  // Clear any old errors
  clearNote('gitlab-comment');

  setInProgressState();

  const commentText = document.getElementById('gitlab-comment').value.trim();

  if (!commentText) {
    postError('Your comment appears to be empty.', 'gitlab-comment');
    resetCommentBox();
    return;
  }

  const detailText = `
 \n
<details>
  <summary>Metadata</summary>
  Posted from ${href} | ${platform} | ${browser} | ${innerWidth} x ${innerHeight}.
  <br /><br />
  <em>User agent: ${userAgent}</em>
</details>
  `;

  const url = `
    ${mrUrl}/api/v4/projects/${projectId}/merge_requests/${mergeRequestId}/discussions`;

  const body = `${commentText} ${detailText}`;

  fetch(url, {
    method: 'POST',
    headers: {
      'PRIVATE-TOKEN': token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ body }),
  })
    .then(response => {
      if (response.ok) {
        confirmAndClear(mergeRequestId);
        return;
      }

      throw new Error(`${response.status}: ${response.statusText}`);
    })
    .catch(err => {
      postError(
        `The feedback was not sent successfully. Please try again. Error: ${err.message}`,
        'gitlab-comment',
      );
      resetCommentBox();
    });
}

export { comment, postComment }
