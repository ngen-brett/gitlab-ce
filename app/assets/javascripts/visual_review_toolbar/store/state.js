import {
  comment,
  login,
  mrForm,
  COMMENT_BOX,
  LOGIN,
  MR_ID,
 } from '../components';

const state = {
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

// adapted from https://developer.mozilla.org/en-US/docs/Web/API/Window/navigator#Example_2_Browser_detect_and_return_an_index
const getBrowserId = sUsrAg => {
  /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
  const aKeys = ['MSIE', 'Edge', 'Firefox', 'Safari', 'Chrome', 'Opera'];
  let nIdx = aKeys.length - 1;

  for (nIdx; nIdx > -1 && sUsrAg.indexOf(aKeys[nIdx]) === -1; nIdx -= 1);
  return aKeys[nIdx];
};

const nextView = (state, form = 'none') => {

  const formsList = {
    [COMMENT_BOX]: () => state.token ? mrForm : login,
    [LOGIN]: (state) => state.mergeRequestId ? comment(state) : mrForm,
    [MR_ID]: (state) => state.token ? comment(state) : login,
    none: (state) => {
      if (!state.token) {
        return login;
      } else if (!state.mergeRequestId) {
        return mrForm
      } else {
        return comment(state)
      }
    }
  };

  return formsList[form](state)
}

const initializeState = (wind, doc) => {
  const {
    innerWidth,
    innerHeight,
    location: { href },
    navigator: { platform, userAgent },
  } = wind;

  const browser = getBrowserId(userAgent);

  const scriptEl = doc.getElementById('review-app-toolbar-script');
  const { projectId, mergeRequestId, mrUrl, projectPath } = scriptEl.dataset;

  // This mutates our default state object above. It's weird but it makes the linter happy.
  Object.assign(state, {
    browser,
    href,
    innerWidth,
    innerHeight,
    // mergeRequestId,
    mrUrl,
    platform,
    projectId,
    projectPath,
    userAgent,
  });

  return state;
};

const getInitialView = ({ localStorage }) => {
  try {
    const token = localStorage.getItem('token');
    const mrId = localStorage.getItem('mergeRequestId');

    if (token) {
      state.token = token;
    }

    if (mrId) {
      state.mergeRequestId = mrId;
    }
  } finally {
    return nextView(state);
  }
}

export { initializeState, getInitialView, nextView, state };
