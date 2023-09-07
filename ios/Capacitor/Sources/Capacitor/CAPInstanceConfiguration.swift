import Foundation

extension InstanceConfiguration {
     var appStartFileURL: URL {
        if let path = appStartPath {
            return appLocation.appendingPathComponent(path)
        }
        return appLocation
    }

     var appStartServerURL: URL {
        if let path = appStartPath {
            return serverURL.appendingPathComponent(path)
        }
        return serverURL
    }

     var errorPathURL: URL? {
        guard let errorPath = errorPath else {
            return nil
        }

        return localURL.appendingPathComponent(errorPath)
    }

    @available(*, deprecated, message: "Use getPluginConfig")
     public func getPluginConfigValue(_ pluginId: String, _ configKey: String) -> Any? {
        return (pluginConfigurations as? JSObject)?[keyPath: KeyPath("\(pluginId).\(configKey)")]
    }

     public func getPluginConfig(_ pluginId: String) -> PluginConfig {
        if let cfg = (pluginConfigurations as? JSObject)?[keyPath: KeyPath("\(pluginId)")] as? JSObject {
            return PluginConfig(config: cfg)
        }
        return PluginConfig(config: JSObject())
    }

     public func shouldAllowNavigation(to host: String) -> Bool {
        for hostname in allowedNavigationHostnames {
            if doesHost(host, match: hostname) {
                return true
            }
        }
        return false
    }

    // MARK: - Private

    private func doesHost(_ host: String, match pattern: String) -> Bool {
        // bail early in the simple case
        if pattern == "*" {
            return true
        }
        // break apart the pieces
        var hostComponents = host.lowercased().split(separator: ".")
        var patternComponents = pattern.lowercased().split(separator: ".")
        guard hostComponents.count == patternComponents.count else {
            return false
        }
        // remove any wildcard segments
        for wildcard in patternComponents.enumerated().reversed().filter({ $0.element == "*" }) {
            hostComponents.remove(at: wildcard.offset)
            patternComponents.remove(at: wildcard.offset)
        }
        // match with what's left
        return hostComponents == patternComponents
    }
}
