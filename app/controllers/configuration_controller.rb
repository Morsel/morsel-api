class ConfigurationController < ApiController
  public_actions << def show
    render_json(non_username_paths: ReservedPaths.non_username_paths)
  end
end
