class ConfigurationController < ApiController
  public_actions << def show
    render_json(non_username_paths: ReservedPaths.non_username_paths)
  end

  def api_key_check
    render_json_ok
  end
end
