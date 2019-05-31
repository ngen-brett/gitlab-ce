import {
  authorizeUser,
  logoutUser,
  postComment,
  toggleForm,
} from '../components';

import state from './state';

const noop = () => {};

const eventLookup = ({ target: { id } }) => {
  switch (id) {
    case 'gitlab-collapse':
      return toggleForm;
    case 'gitlab-comment-button':
      return postComment.bind(null, state);
    case 'gitlab-login':
      return authorizeUser.bind(null, state);
    case 'gitlab-logout-button':
      return logoutUser;
    default:
      return noop;
  }
};

const updateWindowSize = (wind) => {
  state.innerWidth = wind.innerWidth;
  state.innerHeight = wind.innerHeight;
  console.log(state);
}

export { eventLookup, updateWindowSize };
