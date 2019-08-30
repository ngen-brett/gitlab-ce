import Vue from 'vue';
import Vuex from 'vuex';
import CreateEKSCluster from './components/create_eks_cluster.vue';
import createStore from './store';

Vue.use(Vuex);

export default () =>
  new Vue({
    el: '.js-create-eks-cluster-form-container',
    store: createStore(),
    components: {
      CreateEKSCluster,
    },
    data() {},
    render(createElement) {
      return createElement('create-eks-cluster');
    },
  });
