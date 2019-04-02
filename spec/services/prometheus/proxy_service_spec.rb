# frozen_string_literal: true

require 'spec_helper'

describe Prometheus::ProxyService do
  include ReactiveCachingHelpers

  set(:project) { create(:project) }
  set(:environment) { create(:environment, project: project) }

  describe '#execute' do
    let(:prometheus_adapter) { instance_double(PrometheusService) }

    subject { described_class.new(environment, 'GET', 'query', { query: '1' }) }

    context 'When prometheus_adapter is nil' do
      before do
        allow(environment).to receive(:prometheus_adapter).and_return(nil)
      end

      it 'should return error' do
        expect(subject.execute).to eq({
          status: :error,
          message: 'No prometheus server found',
          http_status: :service_unavailable
        })
      end
    end

    context 'When prometheus_adapter cannot query' do
      before do
        allow(environment).to receive(:prometheus_adapter).and_return(prometheus_adapter)
        allow(prometheus_adapter).to receive(:can_query?).and_return(false)
      end

      it 'should return error' do
        expect(subject.execute).to eq({
          status: :error,
          message: 'No prometheus server found',
          http_status: :service_unavailable
        })
      end
    end

    context 'Cannot proxy' do
      subject { described_class.new(environment, 'POST', 'query', { query: '1' }) }

      it 'returns error' do
        expect(subject.execute).to eq({
          message: 'Proxy support for this API is not available currently',
          status: :error
        })
      end
    end

    context 'When cached', :use_clean_rails_memory_store_caching do
      let(:return_value) { { 'http_status' => 200, 'body' => 'body' } }
      let(:opts) { [environment.class.name, environment.id, 'GET', 'query', { 'query' => '1' }] }

      before do
        stub_reactive_cache(subject, return_value, opts)

        allow(environment).to receive(:prometheus_adapter)
          .and_return(prometheus_adapter)
        allow(prometheus_adapter).to receive(:can_query?).and_return(true)
      end

      it 'returns cached value' do
        result = subject.execute

        expect(result[:http_status]).to eq(return_value[:http_status])
        expect(result[:body]).to eq(return_value[:body])
      end
    end

    context 'When not cached' do
      let(:return_value) { { 'http_status' => 200, 'body' => 'body' } }
      let(:opts) { [environment.class.name, environment.id, 'GET', 'query', { 'query' => '1' }] }

      before do
        allow(environment).to receive(:prometheus_adapter)
          .and_return(prometheus_adapter)
        allow(prometheus_adapter).to receive(:can_query?).and_return(true)
      end

      it 'returns nil' do
        expect(ReactiveCachingWorker)
          .to receive(:perform_async)
          .with(subject.class, subject.id, *opts)

        result = subject.execute

        expect(result).to eq(nil)
      end
    end

    context 'Call prometheus api' do
      let(:prometheus_client) { instance_double(Gitlab::PrometheusClient) }

      before do
        synchronous_reactive_cache(subject)

        allow(environment).to receive(:prometheus_adapter)
          .and_return(prometheus_adapter)
        allow(prometheus_adapter).to receive(:can_query?).and_return(true)
        allow(prometheus_adapter).to receive(:prometheus_client_wrapper)
          .and_return(prometheus_client)
      end

      context 'Connection to prometheus server succeeds' do
        let(:rest_client_response) { instance_double(RestClient::Response) }

        before do
          allow(prometheus_client).to receive(:proxy).and_return(rest_client_response)

          allow(rest_client_response).to receive(:code)
            .and_return(prometheus_http_status_code)
          allow(rest_client_response).to receive(:body).and_return(response_body)
        end

        shared_examples 'return prometheus http status code and body' do
          it do
            expect(subject.execute).to eq({
              http_status: prometheus_http_status_code,
              body: response_body,
              status: :success
            })
          end
        end

        context 'prometheus returns success' do
          let(:prometheus_http_status_code) { 200 }

          let(:response_body) do
            '{"status":"success","data":{"resultType":"scalar","result":[1553864609.117,"1"]}}'
          end

          before do
          end

          it_behaves_like 'return prometheus http status code and body'
        end

        context 'prometheus returns error' do
          let(:prometheus_http_status_code) { 400 }

          let(:response_body) do
            '{"status":"error","errorType":"bad_data","error":"parse error at char 1: no expression found in input"}'
          end

          it_behaves_like 'return prometheus http status code and body'
        end
      end

      context 'connection to prometheus server fails' do
        context 'prometheus client raises Gitlab::PrometheusClient::Error' do
          before do
            allow(prometheus_client).to receive(:proxy)
              .and_raise(Gitlab::PrometheusClient::Error, 'Network connection error')
          end

          it 'returns error' do
            expect(subject.execute).to eq({
              status: :error,
              message: 'Network connection error',
              http_status: :service_unavailable
            })
          end
        end
      end
    end
  end

  describe '.from_cache' do
    it 'initializes an instance of ProxyService class' do
      result = described_class.from_cache(environment.class.name, environment.id, 'GET', 'query', { query: '1' })

      expect(result).to be_an_instance_of(described_class)
      expect(result.prometheus_owner).to eq(environment)
      expect(result.method).to eq('GET')
      expect(result.path).to eq('query')
      expect(result.params).to eq({ query: '1' })
    end
  end
end
