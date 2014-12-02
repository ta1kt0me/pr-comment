require "pr/comment/version"
require "pr/comment/cli"

module Pr
  module Comment

    class PRComment
      attr_accessor :user, :comment, :created_at, :review

      def initialize(comment, review = nil)
        @user       = comment[:user][:login]
        @comment_id = comment[:id]
        @comment    = comment[:body]
        @created_at = comment[:created_at]
        @review     = review
      end

      def pull_or_issue
        if @review then 'R' else 'C' end
      end
    end

    class Review
      attr_accessor :diff_hunk, :path, :position, :commit_id

      def initialize(comment)
        @diff_hunk    = comment[:diff_hunk]
        @path         = comment[:path]
        @position     = comment[:original_position]
        @commit_id    = comment[:original_commit_id]
        @now_position = comment[:position]
      end

      def == obj
        if @diff_hunk == obj.diff_hunk && @path == obj.path && @position == obj.position && @commit_id == obj.commit_id
          true
        else
          false
        end
      end

      def closed?
        if @now_position == @position then false else true end
      end

      def diffs
        @diff_hunk.split(/(\n|\r\n|\r)++/)
      end
    end

    class CollectedComments
      attr_accessor :comments

      def initialize
        @comments = []
      end

      def summarize_and_sort
        @comments.each_with_object(summarized_comments = []) {|comment|
          summarized_comments.each {|e|
            break if comment.review.nil?
            e << comment if e[0].review == comment.review
          }
          summarized_comments << [comment] unless summarized_comments.flatten.include? comment
        }
        summarized_comments.sort!{|a, b| a[0].created_at <=> b[0].created_at }
      end

      def add_issue_comment!(client, repo, pr_no)
        @comments += client.issue_comments(repo, pr_no).map do |comment|
          Pr::Comment::PRComment.new(comment)
        end
      end

      def add_pr_comment!(client, repo, pr_no)
        @comments += client.pull_request_comments(repo, pr_no).map do |comment|
          Pr::Comment::PRComment.new(comment, Pr::Comment::Review.new(comment))
        end
      end

      def exclude_close_comments!
        self.tap { @comments.select! {|e| !e.review.nil? && e.review.closed? } }
      end
    end
  end
end
