import { comment } from './comment';
import { login } from './login';
import { commentIcon, compressIcon } from './wrapper_icons';

const form = content => `
  <div id='gitlab-form-wrapper'>
    ${content}
  </div>
`;

const addCommentForm = () => {
  const formWrapper = document.getElementById('gitlab-form-wrapper');
  formWrapper.innerHTML = comment;
}

const addLoginForm = () => {
  const formWrapper = document.getElementById('gitlab-form-wrapper');
  formWrapper.innerHTML = login;
}

function logoutUser() {
  const { localStorage } = window;

  // All the browsers we support have localStorage, so let's silently fail
  // and go on with the rest of the functionality.
  try {
    localStorage.removeItem('token');
  } catch (err) {
    return;
  }

  addLoginForm();
}

function toggleForm() {
  const container = document.getElementById('gitlab-review-container');
  const collapseButton = document.getElementById('gitlab-collapse');
  const currentForm = document.getElementById('gitlab-form-wrapper');
  const OPEN = 'open';
  const CLOSED = 'closed';

  const stateVals = {
    [OPEN]: {
      buttonClasses: ['gitlab-collapse-closed', 'gitlab-collapse-open'],
      containerClasses: ['gitlab-closed-wrapper', 'gitlab-open-wrapper'],
      icon: compressIcon,
      display: 'flex',
      backgroundColor: 'rgba(255, 255, 255, 1)',
    },
    [CLOSED]: {
      buttonClasses: ['gitlab-collapse-open', 'gitlab-collapse-closed'],
      containerClasses: ['gitlab-open-wrapper', 'gitlab-closed-wrapper'],
      icon: commentIcon,
      display: 'none',
      backgroundColor: 'rgba(255, 255, 255, 0)',
    },
  };

  const nextState = collapseButton.classList.contains('gitlab-collapse-open') ? CLOSED : OPEN;

  container.classList.replace(...stateVals[nextState].containerClasses);
  container.style.backgroundColor = stateVals[nextState].backgroundColor;
  currentForm.style.display = stateVals[nextState].display;
  collapseButton.classList.replace(...stateVals[nextState].buttonClasses);
  collapseButton.innerHTML = stateVals[nextState].icon;
}

export { addCommentForm, addLoginForm, form, logoutUser, toggleForm }
