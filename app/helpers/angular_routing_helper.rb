module AngularRoutingHelper
  include ActionDispatch::Routing
  include ActionDispatch::Integration::Runner
  include Rails.application.routes.url_helpers

  DIRECTORY_PATH_SEPARATOR = '/'

  def getAllAngularRoutes
    routes = []

    Rails.application.routes.routes.each do |route|
      path = angularRouteRawPath(route.path.spec.to_s)

      if path.start_with?(app_root_path) &&
         path != (app_templates_path + '/:path.html') &&
         path != app_root_path
        routes.push path
      end
    end

    routes
  end

  def angularRouteAppPath(route)
    ('#' + route).sub(app_templates_path.sub(/\s*\(.+\)$/, ''), '') + ((route != app_templates_path && isRouteAScope(route)) ? '/index' : '')
  end

  def angularRouteFilePath(route)
    route.gsub(/^\/|(\/)+$|\/:[^\/]*/, '').sub(/(\/new)+$/, '/edit') + (isRouteAScope(route) ? '/index' : '') + '.html'
  end

  def angularRouteRawPath(route)
    route.sub(/\s*\(.+\)$/, '')
  end

  def isRouteAScope(route)
    scopes = []

    Rails.application.routes.routes.each do |route|
      path = angularRouteRawPath(route.path.spec.to_s)
      path[0] = ''

      paths = path.split(DIRECTORY_PATH_SEPARATOR)
      paths.pop
      paths.each do |scope|
        next if scope.include? ':'
        scopes.push scope if !scopes.include? scope
      end
    end

    routeWithoutLeadingSlash = route
    routeWithoutLeadingSlash[0] = ''
    endPath = routeWithoutLeadingSlash.split(DIRECTORY_PATH_SEPARATOR).last

    scopes.include? endPath
  end
end
