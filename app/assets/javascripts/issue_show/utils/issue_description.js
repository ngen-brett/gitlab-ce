/**
 * Function that replaces the open attribute for the <details> element.
 *
 * @param {String} descriptionHtml - The html string passed back from the server as a result of polling
 * @param {Array} details - All detail nodes inside of the issue description.
 */

const updateDetailsState = (descriptionHtml = '', details = []) => {
  const placeholder = document.createElement('div');

  placeholder.innerHTML = descriptionHtml;

  placeholder.querySelectorAll('details').forEach((el, i) => {
    const matchingCurrentEl = details[i];

    el.open = matchingCurrentEl.open;
  });

  return placeholder.innerHTML;
}

export { updateDetailsState };