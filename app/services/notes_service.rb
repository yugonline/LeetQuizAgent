class NotesService
  def initialize
    @gh = GithubNotesService.new(
      repo: ENV["GITHUB_NOTES_REPO"],
      token: ENV["GITHUB_ACCESS_TOKEN"]  # nil if public
    )
  end

  def fetch_notes_for_date(date)
    # Fetch markdown files committed today
    committed_files = @gh.list_committed_markdown_files(date)

    # Download content of each file
    committed_files.map do |file|
      content = @gh.download_file(file["raw_url"])
      {
        name: file["filename"],
        content: content
      }
    end
  end
end
