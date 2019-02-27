import { viewerInformationForPath } from '~/vue_shared/components/content_viewer/lib/viewer_utils';
import { decorateData, sortTree } from '../stores/utils';

// eslint-disable-next-line import/prefer-default-export
export const decorateFiles = ({
  data,
  projectId,
  branchId,
  tempFile = false,
  content = '',
  base64 = false,
}) => {
  const treeList = [];
  const entries = {};
  let file;
  let parentPath;

  const splitParent = path => {
    const idx = path.lastIndexOf('/');

    return {
      parent: idx >= 0 ? path.substring(0, idx) : null,
      name: idx >= 0 ? path.substring(idx + 1) : path,
    };
  };

  const insertParent = path => {
    if (!path) {
      return null;
    } else if (entries[path]) {
      return entries[path];
    }

    const { parent, name } = splitParent(path);
    const parentFolder = parent && insertParent(parent);
    const folderPath = path;
    parentPath = parentFolder ? parentFolder.path : null;

    const tree = decorateData({
      projectId,
      branchId,
      id: folderPath,
      name,
      path: folderPath,
      url: `/${projectId}/tree/${branchId}/-/${folderPath}/`,
      type: 'tree',
      parentTreeUrl: parentFolder ? parentFolder.url : `/${projectId}/tree/${branchId}/`,
      tempFile,
      changed: tempFile,
      opened: tempFile,
      parentPath,
    });

    Object.assign(entries, {
      [folderPath]: tree,
    });

    if (parentFolder) {
      parentFolder.tree.push(tree);
    } else {
      treeList.push(tree);
    }

    return tree;
  };

  data.forEach(path => {
    const { parent, name } = splitParent(path);

    const fileFolder = parent && insertParent(parent);

    if (name) {
      parentPath = fileFolder && fileFolder.path;

      file = decorateData({
        projectId,
        branchId,
        id: path,
        name,
        path,
        url: `/${projectId}/blob/${branchId}/-/${path}`,
        type: 'blob',
        parentTreeUrl: fileFolder ? fileFolder.url : `/${projectId}/blob/${branchId}`,
        tempFile,
        changed: tempFile,
        content,
        base64,
        previewMode: viewerInformationForPath(name),
        parentPath,
      });

      Object.assign(entries, {
        [path]: file,
      });

      if (fileFolder) {
        fileFolder.tree.push(file);
      } else {
        treeList.push(file);
      }
    }
  });

  return {
    entries,
    treeList: sortTree(treeList),
    file,
    parentPath,
  };
};
