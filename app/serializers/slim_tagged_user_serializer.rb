class SlimTaggedUserSerializer < SlimUserSerializer
  attributes :tagged

  def tagged
    morsel && morsel.tagged_user?(object)
  end

  private

  def morsel
    options[:context][:morsel] if options[:context]
  end
end
