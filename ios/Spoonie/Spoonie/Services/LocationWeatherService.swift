import CoreLocation
import Foundation

enum LocationWeatherError: Error {
    case denied
    case unavailable
}

final class LocationWeatherService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func requestWeatherContext() async throws -> WeatherContext {
        let location = try await requestLocation()
        async let cityTask = resolveCity(from: location)
        async let weatherTask = fetchOpenMeteoWeather(location: location)
        let city = try await cityTask
        let raw = try await weatherTask
        return WeatherNarrativeService.makeContext(city: city, raw: raw)
    }

    private func requestLocation() async throws -> CLLocation {
        let authorization = manager.authorizationStatus
        guard authorization != .denied && authorization != .restricted else {
            throw LocationWeatherError.denied
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            if authorization == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                manager.requestLocation()
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            locationContinuation?.resume(throwing: LocationWeatherError.denied)
            locationContinuation = nil
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationContinuation?.resume(throwing: LocationWeatherError.unavailable)
            locationContinuation = nil
            return
        }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }

    private func resolveCity(from location: CLLocation) async throws -> String {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        let mark = placemarks.first
        return mark?.locality ?? mark?.administrativeArea ?? "当前位置"
    }

    private func fetchOpenMeteoWeather(location: CLLocation) async throws -> RawWeather {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else { throw LocationWeatherError.unavailable }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        return RawWeather(
            temperature: response.current.temperature2m,
            humidity: response.current.relativeHumidity2m,
            weatherCode: response.current.weatherCode,
            windSpeed: response.current.windSpeed10m
        )
    }
}

struct RawWeather {
    var temperature: Double
    var humidity: Double
    var weatherCode: Int
    var windSpeed: Double
}

private struct OpenMeteoResponse: Decodable {
    let current: Current

    struct Current: Decodable {
        let temperature2m: Double
        let relativeHumidity2m: Double
        let weatherCode: Int
        let windSpeed10m: Double

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
        }
    }
}

enum WeatherNarrativeService {
    static func makeContext(city: String, raw: RawWeather) -> WeatherContext {
        let condition = conditionText(code: raw.weatherCode, humidity: raw.humidity, wind: raw.windSpeed)
        let narrative: String
        if raw.humidity >= 82 {
            narrative = "\(city) · 空气湿湿的，像什么都散得慢一点"
        } else if raw.windSpeed >= 24 {
            narrative = "\(city) · 外面风有点硬，声音也容易变大"
        } else if raw.temperature >= 30 {
            narrative = "\(city) · 热气贴着人，今天更需要慢一点"
        } else {
            narrative = "\(city) · \(condition)"
        }

        return WeatherContext(
            city: city,
            narrative: narrative,
            shortText: "\(city) · \(condition)",
            source: "open-meteo+local-narrative"
        )
    }

    private static func conditionText(code: Int, humidity: Double, wind: Double) -> String {
        switch code {
        case 0:
            return wind > 18 ? "晴，有风" : "天气清清的"
        case 1...3:
            return humidity > 75 ? "云有点厚" : "云慢慢飘着"
        case 45, 48:
            return "微风有雾"
        case 51...67, 80...82:
            return "有雨意"
        case 71...77, 85...86:
            return "有雪意"
        case 95...99:
            return "雷声靠近"
        default:
            return "天气轻轻路过"
        }
    }
}
