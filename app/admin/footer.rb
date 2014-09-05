module ActiveAdmin
  module Views
    class Footer < Component
      def build
        super id: 'footer'
        super style: 'text-align: right;'

        div do
          small %(Deployed Commit: #{link_to(`git rev-parse --short HEAD`, "https://github.com/morsel/morsel-api/commit/#{`git rev-parse HEAD`}")}).html_safe
        end
      end
    end
  end
end
