# frozen_string_literal: true
require 'slack-notifier'

module ChatMessage
  class PipelineMessage < BaseMessage
    attr_reader :ref_type
    attr_reader :ref
    attr_reader :commit_message
    attr_reader :commit_url
    attr_reader :status
    attr_reader :duration
    attr_reader :finished_at
    attr_reader :pipeline_id
    attr_reader :stages
    attr_reader :failed_jobs

    def initialize(data)
      super

      @user_name = data.dig(:user, :username) || 'API'

      pipeline_attributes = data[:object_attributes]
      @ref_type = pipeline_attributes[:tag] ? 'tag' : 'branch'
      @ref = pipeline_attributes[:ref]
      @commit_message = data.dig(:commit, :message)
      @commit_url = data.dig(:commit, :url)
      @status = pipeline_attributes[:status]
      @duration = pipeline_attributes[:duration].to_i
      @finished_at = Time.parse(pipeline_attributes[:finished_at]).to_i
      @pipeline_id = pipeline_attributes[:id]
      @stages = pipeline_attributes[:stages]
      @failed_jobs = (data[:builds] || []).select { |b| b[:status] == 'failed' }
    end

    def pretext
      ''
    end

    def attachments
      return message if markdown

      [{
        fallback: format(message),
        color: attachment_color,
        author_name: user_combined_name,

        # How do we get this?
        # author_link: 'https://gitlab.com/nfriend',

        author_icon: user_avatar,
        title: "Pipeline #{pipeline_id} #{humanized_status}",
        title_link: pipeline_url,
        fields: [
          {
            title: 'Failed stage'.pluralize(stages.length),
            value: stages.join(', '),
            short: true
          },
          {
            title: ref_type.capitalize,
            value: ref,
            short: true
          },
          {
            title: 'Failed job'.pluralize(failed_jobs.length),
            value: failed_jobs_slack_links,
            short: true
          },
          {
            title: 'Commit',
            value: commit_slack_link,
            short: false
          }
        ],
        footer: project_name,
        # footer_icon: project_avatar,
        footer_icon: 'https://assets.gitlab-static.net/uploads/-/system/project/avatar/13083/logo-extra-whitespace.png?width=64',
        ts: finished_at
      }]
    end

    def activity
      {
        title: "Pipeline #{pipeline_link} of #{ref_type} #{branch_link} by #{user_combined_name} #{humanized_status}",
        subtitle: "in #{project_link}",
        text: "in #{pretty_duration(duration)}",
        image: user_avatar || ''
      }
    end

    private

    def message
      "#{project_link}: Pipeline #{pipeline_link} of #{ref_type} #{branch_link} by #{user_combined_name} #{humanized_status} in #{pretty_duration(duration)}"
    end

    def humanized_status
      case status
      when 'success'
        'passed'
      else
        status
      end
    end

    def attachment_color
      if status == 'success'
        'good'
      else
        'danger'
      end
    end

    def branch_url
      "#{project_url}/commits/#{ref}"
    end

    def branch_link
      "[#{ref}](#{branch_url})"
    end

    def project_link
      "[#{project_name}](#{project_url})"
    end

    def pipeline_url
      "#{project_url}/pipelines/#{pipeline_id}"
    end

    def pipeline_link
      "[##{pipeline_id}](#{pipeline_url})"
    end

    def failed_jobs_slack_links
      job_links = failed_jobs.map do |job|
        # Is there a better way to get the job URL?
        "<#{project_url}/-/jobs/#{job[:id]}|#{job[:name]}>"
      end

      job_links.join(', ')
    end

    def commit_slack_link
      commit_summary = commit_message.split("\n").first
      "<#{commit_url}|#{commit_summary}>"
    end
  end
end
