import _ from 'underscore';

/**
 * Parses the job log content into a structure usable by the template
 *
 * For collaspible lines (section_header = true):
 *    - creates a new array to hold the lines that are collpasible,
 *    - adds a isClosed property to handle toggle
 *    - adds a isHeader property to handle template logic
 * For each line:
 *    - adds the index as  lineNumber
 *
 * @param {Array} lines
 * @returns {Array}
 */
export const logLinesParser = (lines = []) =>
  lines.reduce((acc, line, index) => {
    if (line.section_header) {
      acc.push({
        isClosed: true,
        isHeader: true,
        line: {
          ...line,
          lineNumber: index,
        },

        lines: [],
      });
    } else if (acc.length && acc[acc.length - 1].isHeader) {
      acc[acc.length - 1].lines.push({
        ...line,
        lineNumber: index,
      });
    } else {
      acc.push({
        ...line,
        lineNumber: index,
      });
    }

    return acc;
  }, []);

/**
 * When the trace is not complete, backend may send the last received line
 * in the new response.
 *
 * We need to check if that is the case by looking for the offset property
 * before parsing the incremental part
 */
export const updateIncrementalTrace = (oldLog, newLog) => {
  const firstLine = newLog[0];
  const firstLineOffset = firstLine.offset;
  let newParsedLog;

  // We are going to return a new array, let's make a shallow copy to make sure we
  // are not updating the state outside of a mutation first.
  const cloneOldLog = [...oldLog];
  const lastLine = cloneOldLog[cloneOldLog.length - 1];

  // The last line may be inside a collpasible section, let's look for it
  if (lastLine.isHeader) {
    if (lastLine.lines.length) {
      const lastLineSection = lastLine.lines[lastLine.lines.length - 1];
      if (lastLineSection.offset === firstLineOffset) {
        // this is the one that needs to be replaced

        // if inside a section, the following lines may belong to the same section
        if (_.intersection(lastLine.sections, firstLine.sections).length) {
        }
      }
    }

    if (lastLine.offset === firstLineOffset) {
      // this is the one that needs to be replaced
    }
  } else if (lastLine.offset === firstLineOffset) {
    // replace this one
  } else {
    // there are no matches, let's parse the new log and return them together
    newParsedLog = cloneOldLog.concat(logLinesParser(newLog));
  }

  return newParsedLog;
};

export const isNewJobLogActive = () => gon && gon.features && gon.features.jobLogJson;
