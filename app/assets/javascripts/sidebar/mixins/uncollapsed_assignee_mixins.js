export default {
  props: {
    user: {
      type: Object,
      required: true,
    },
    rootPath: {
      type: String,
      required: true,
    },
  },
  methods: {
    assigneeUrl(user) {
      return `${this.rootPath}${user.username}`;
    },
  },
};
