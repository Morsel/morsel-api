class ConfigurationController < ApiController
  PUBLIC_ACTIONS << def show
    render_json(non_username_paths: ReservedPaths.non_username_paths)
  end

  PUBLIC_ACTIONS << def proxy
    render file: 'public/proxy.html'
  end
end
