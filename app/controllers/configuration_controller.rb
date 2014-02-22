class ConfigurationController < ApiController
  def show
    render_json(json)
  end

  private

  def json
    {
      non_username_paths: ReservedPaths.non_username_paths
    }
  end
end
