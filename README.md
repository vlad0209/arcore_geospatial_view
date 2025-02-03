# ARCore Geospatial View

ARCore Geospatial View is a **Flutter package** that offers tools to render augmented reality (AR) annotations using **geospatial data**. It works with **Google ARCore** to show interactive **points of interest (POIs)** in an AR experience helping users see **real-world locations** with annotations.

## 📌 Features

- **AR Annotations**: Show markers based on location and device orientation.
- **Geospatial Tracking**: Uses **ARCore's Geospatial API** to find device pose (latitude, longitude, altitude, heading, pitch).
- **Real-time AR Updates**: Changes POIs as the user moves.
- **Customizable Annotations**: Define how your annotations look with a builder function.
- **Debug Mode**: Shows real-time geospatial data.

## 🛠 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  arcore_geospatial_view:
    git: https://github.com/vlad0209/arcore_geospatial_view.git
```

Then run:

```sh
flutter pub get
```

## 🚀 How to Use

### 1️⃣ Make ARCore work

#### Turn on ARCore API in Google Cloud

1. Head to the [Google Cloud Console](https://console.cloud.google.com/).
2. Pick your project or make a new one.
3. Go to **APIs & Services > Library**.
4. Look up **ARCore API** and switch it on.
5. Visit **APIs & Services > Credentials** and set up a new API key.

#### Android Setup

Ensure **Google Play Services for AR** is on your device. For Android add these lines to `AndroidManifest.xml`:

#### If AR is **optional**:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<meta-data android:name="com.google.ar.core" android:value="optional" />
```

#### If AR is **necessary**:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<meta-data android:name="com.google.ar.core" android:value="required" />
```

#### Set up Google AR API Key

To add geospatial features insert this into your `AndroidManifest.xml`:

```xml
<meta-data android:name="com.google.android.ar.API_KEY" android:value="YOUR_API_KEY_HERE" />
```

Switch out `YOUR_API_KEY_HERE` with your real **Google Cloud API Key**.

#### iOS Setup

This package uses the **permission_handler** plugin to check and ask for camera access. On **iOS**, you need to change your **Podfile** to allow permissions.

Go to the **iOS folder** in your Flutter project and open the **Podfile** (`ios/Podfile`). Find the `post_install` function and put these lines in it:

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # Enable required permissions
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',  # Enable camera permission
        'PERMISSION_LOCATION_WHEN_IN_USE=1'  # Enable location permission
      ]
    end
  end
end
```

For iOS, add the following permissions in your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show AR annotations accurately.</string>

<key>NSCameraUsageDescription</key>
<string>We need camera access for augmented reality features.</string>
```

### 2️⃣ Bring in the Package

```dart
import 'package:arcore_geospatial_view/arcore_geospatial_view.dart';
```

### 3️⃣ Create Your Own Annotation Class

`ArAnnotation` has an abstract structure. You need to extend it to make your own annotation models.

```dart
class CustomArAnnotation extends ArAnnotation {
  CustomArAnnotation({required String uid, required Position position})
      : super(uid: uid, position: position);
}
```

### 4️⃣ Set Up the AR Widget

```dart
ArcoreGeospatialWidget(
  annotations: [
    CustomArAnnotation(
      uid: "poi_1",
      position: Position(latitude: 37.7749, longitude: -122.4194),
    ),
  ],
  annotationViewBuilder: (context, annotation) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(8),
      child: Text(annotation.uid, style: TextStyle(color: Colors.white)),
    );
  },
  onLocationChange: (newLocation) {
    print("New location: ${newLocation.latitude}, ${newLocation.longitude}");
  },
  showDebugInfo: true,
  iosApiKey: "YOUR_API_KEY_HERE" // API key here is required for iOS only, for Android you just put it in the AndroidManifest.xml as shown above
);
```
## Prepaire the app to release

When building a minified app, the Geospatial API requires the GMS location modules to be unminified. Keep the GMS authentication libraries as-is when using Keyless Authentication. Add the following lines to the android/app/proguard-rules.pro file:

```
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
```


📌 API Reference

### `ArcoreGeospatialWidget`

| Property                | Type                                          | Description                                                   |
| ----------------------- | --------------------------------------------- | ------------------------------------------------------------- |
| `annotations`           | `List<ArAnnotation>`                          | List of AR annotations. You need to extend `ArAnnotation`.    |
| `annotationViewBuilder` | `Widget Function(BuildContext, ArAnnotation)` | Function that creates the annotation UI.                      |
| `onLocationChange`      | `ChangeLocationCallback`                      | Callback when the user's location changes.                    |
| `annotationWidth`       | `double`                                      | Width of annotation widgets.                                  |
| `annotationHeight`      | `double`                                      | Height of annotation widgets.                                 |
| `showDebugInfo`         | `bool`                                        | Shows debug information for latitude, longitude, and orientation. |

## ⚠️ Limitations

- You need a device that works with ARCore to use this.
- If you have an iPhone or iPad, your device must support ARKit.

## 🤝 Contributing

I'd love your help! Don't hesitate to report issues or send in pull requests.

## 📄 License

You can use this project under the MIT License. Check out the [LICENSE](LICENSE) file to learn more.

---

📌 I made this with love for people who build AR apps with Flutter! 🚀

