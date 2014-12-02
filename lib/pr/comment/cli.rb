require 'pr/comment'
require 'thor'
require 'octokit'
module PR
  module Comment
    class CLI < Thor

      default_command :all

      desc "all ORG/REPO PR_NO", "print all pull request comments list to STDOUT."
      def all(repo, pr_no)
        sorted_comments = collected_comments(repo, pr_no).summarize_and_sort
        print_comment(sorted_comments)
      end

      desc "close ORG/REPO PR_NO", "print close pull request comments list to STDOUT."
      def close(repo, pr_no)
        sorted_comments = collected_comments(repo, pr_no).exclude_close_comments!.summarize_and_sort
        print_comment(sorted_comments)
      end

      private
      def collected_comments(repo, pr_no)
        client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
        comments = Pr::Comment::CollectedComments.new
        comments.add_issue_comment!(client, repo, pr_no)
        comments.add_pr_comment!(client, repo, pr_no)
        comments
      end

      def print_comment(sorted_comments)
        sorted_comments.each_with_index do |elem, idx|
          elem.each_with_index do |item, idx|
            if item.review and idx == 0
              say "--- #{item.review.path}", :green
              say "#{item.review.diffs.first}\n#{item.review.diffs.last}", :green
              say '---', :green
            end
            if idx == 0
              say "#{item.pull_or_issue} ", :yellow, false
            else
              say '  ', nil, false
            end
            say "@#{item.user}", :cyan, false
            say " : #{item.comment.gsub(/(\r\n|\r|\n)/, ' ')}\n"
          end
          say '|' if idx + 1 != sorted_comments.size
        end
      end
    end
  end
end
