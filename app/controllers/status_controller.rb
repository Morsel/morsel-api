class StatusController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]
  include JSONEnvelopable

  def show
    respond_to do |format|
      format.html { render(text: response.message) }
      format.json { render_json(nil, response.status) }
    end
  end
end
