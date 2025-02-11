class GithubNotesService
  include HTTParty
  base_uri "https://api.github.com"

  def initialize(repo:, token: nil)
    @repo = repo # e.g. "YourName/obsidian-notes"
    @headers = {
      "User-Agent" => "LeetQuizAgent"
    }
    # If private repo, add Authorization
    @headers["Authorization"] = "Bearer #{token}" if token
  end

  # Fetch commits for a specific date
  def list_committed_markdown_files(date)
    since_date = date.beginning_of_day.utc.iso8601
    until_date = date.end_of_day.utc.iso8601

    url = "/repos/#{@repo}/commits"
    response = self.class.get(url, query: { since: since_date, until: until_date }, headers: @headers)
    return [] unless response.code == 200

    commits = JSON.parse(response.body)
    markdown_files = []

    commits.each do |commit|
      # Fetch file changes for each commit
      commit_url = commit["url"]
      commit_response = self.class.get(commit_url, headers: @headers)
      next unless commit_response.code == 200

      commit_data = JSON.parse(commit_response.body)
      if commit_data["files"]
        markdown_files += commit_data["files"].select { |file| file["filename"].end_with?(".md") }
      end
    end

    markdown_files.uniq { |file| file["filename"] } # Deduplicate by filename
  end

  # Download raw content of a .md file using 'raw_url'
  def download_file(download_url)
    file_res = HTTParty.get(download_url, headers: @headers)
    file_res.body if file_res.code == 200
  end
end
