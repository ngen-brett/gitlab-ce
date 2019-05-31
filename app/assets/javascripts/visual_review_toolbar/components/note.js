const note = `
  <p id='gitlab-validation-note' class='gitlab-message'></p>
`;

const clearNote = (inputId) =>  {
  const currentNote = document.getElementById('gitlab-validation-note');
  currentNote.innerText = '';
  currentNote.style.color = '';

  if (inputId) {
    const field = document.getElementById(inputId);
    field.style.borderColor = '';
  }
}

const postError = (message, inputId) => {
  const currentNote = document.getElementById('gitlab-validation-note');
  const field = document.getElementById(inputId);
  field.style.borderColor = '#db3b21';
  currentNote.style.color = '#db3b21';
  currentNote.innerText = message;
}

export { clearNote, note, postError }
