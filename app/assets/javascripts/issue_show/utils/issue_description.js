/**
 * Function that replaces the open attribute for the <details> element.
 *
 * @param {String} descriptionHtml - The html string passed back from the server as a result of polling
 * @param {Array} details - All detail nodes inside of the issue description.
 */

const updateDetailsState = (descriptionHtml = '', details = []) => {
  const placeholder = document.createElement('div');
  placeholder.innerHTML = descriptionHtml;

  const newDescription = placeholder.querySelectorAll('details')

  if(newDescription.length !== details.length) {
    return descriptionHtml;
  };
  
  newDescription.forEach((el, i) => { el.open = details[i].open });

  return placeholder.innerHTML;
}

export { updateDetailsState };