require 'pr/comment'
require 'thor'
require 'octokit'
module PR
  module Comment
    class CLI < Thor

      default_command :all



      desc "all ORG/REPO PR_NO", "print pull request comments list to STDOUT."
      def all(repo, pr_no)

        client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
        collected_comments = Pr::Comment::CollectedComments.new
        collected_comments.add_issue_comment!(client, repo, pr_no)
        collected_comments.add_pr_comment!(client, repo, pr_no)

        collected_comments.summarize_and_sort.each_with_index do |elem, idx|
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
          say '|' if idx + 1 != collected_comments.summarize_and_sort.size
        end
      end

    end
  end
end
