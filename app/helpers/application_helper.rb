module ApplicationHelper

  def routing_based_javascripts
    asset = routing_based_asset('javascripts')
    asset.nil? ? nil : javascript_include_tag(asset)
  end

  def routing_based_stylesheets
    asset = routing_based_asset('stylesheets')
    asset.nil? ? nil : stylesheet_link_tag(asset)
  end

  private

  def routing_based_asset(options={})
    options = { :asset_type => options } unless options.is_a?(Hash)
    opts = params.merge(options)
    opts[:asset_type] ||= :javascripts
    opts[:asset_uri] ||= File.join(opts[:controller], opts[:action])
    opts[:asset_files] ||= File.join(Rails.root, %w(app assets),
                                     opts[:asset_type].to_s, opts[:asset_uri] + '.*')
    Dir.glob(opts[:asset_files]).empty? ? nil : opts[:asset_uri]
  end

end
