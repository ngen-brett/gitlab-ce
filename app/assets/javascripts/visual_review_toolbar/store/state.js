import { comment, login, collapseButton } from '../components'

// eslint-disable-next-line no-mutable-exports
let state = {
  browser: '',
  href: '',
  innerWidth: '',
  innerHeight: '',
  mergeRequestId: '',
  mrUrl: '',
  platform: '',
  projectId: '',
  userAgent: '',
  token: '',
};

// from https://developer.mozilla.org/en-US/docs/Web/API/Window/navigator
/* eslint-disable no-var, no-plusplus, one-var */

const getBrowserId = (sUsrAg) => {
  var aKeys = ['MSIE', 'Edge', 'Firefox', 'Safari', 'Chrome', 'Opera'],
    nIdx = aKeys.length - 1;

  for (nIdx; nIdx > -1 && sUsrAg.indexOf(aKeys[nIdx]) === -1; nIdx--);
  return aKeys[nIdx];
}

/* eslint-enable no-var, no-plusplus */


const initializeState = (wind, doc) => {

  const {
    innerWidth,
    innerHeight,
    location: { href },
    navigator: { platform, userAgent },
  } = wind;

  const browser = getBrowserId(userAgent);

  const scriptEl = doc.getElementById('review-app-toolbar-script');
  const { projectId, mergeRequestId, mrUrl } = scriptEl.dataset;

  state = {
    ...state,
    browser,
    href,
    innerWidth,
    innerHeight,
    mergeRequestId,
    mrUrl,
    platform,
    projectId,
    userAgent,
  }
};

function getInitialView({ localStorage }) {

  const loginView = {
    content: login,
    toggleButton: collapseButton
  };

  const commentView = {
    content: comment,
    toggleButton: collapseButton
  }

  try {
    const token = localStorage.getItem('token');

    if (token) {
      state.token = token;
      return commentView;
    }
    return loginView;
  } catch (err) {
    return loginView;
  }
}

export { initializeState, getInitialView, state };
