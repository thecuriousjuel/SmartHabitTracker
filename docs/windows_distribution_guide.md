# Windows Distribution Guide

This guide explains how to package the Smart Habit Tracker Flutter application for Windows distribution using the `msix` package. 

## 1. Configuration
The application is configured to build as an `.msix` package, which is the modern Windows installer format. This configuration is defined in the `pubspec.yaml` file under the `msix_config` section:

```yaml
msix_config:
  display_name: Smart Habit Tracker
  publisher_display_name: TheCuriousJuel
  identity_name: TheCuriousJuel.SmartHabitTracker
  logo_path: assets/logo.png
  capabilities: "internetClient, location"
  install_certificate: false
```

## 2. Building the Installer
To generate a new `.msix` installer, simply run the following command from the root of your project:

```bash
dart run msix:create
```

This command automatically:
1. Builds the Windows release version (`flutter build windows`).
2. Packages the built executable and assets into an `.msix` file.
3. Generates a test certificate (if you don't provide your own) and signs the package.

The resulting installer will be located at:
`build\windows\x64\runner\Release\smart_habit_tracker.msix`

## 3. Resolving Installation Issues (Code Signing)
By default, Windows prevents the installation of `.msix` files that are not signed by a trusted Certificate Authority (CA). Because the `msix` tool generates a "self-signed" test certificate for development purposes, you will see an error when trying to install it.

### Option A: Local Testing (Free)
If you just want to install the app on your own machine or a friend's machine without paying for a certificate, you must tell Windows to trust the generated test certificate:
1. Right-click the `.msix` file and select **Properties**.
2. Go to the **Digital Signatures** tab.
3. Select the signature in the list and click **Details**.
4. Click **View Certificate** -> **Install Certificate**.
5. Select **Local Machine** and click Next.
6. Choose **Place all certificates in the following store** and click **Browse**.
7. Select **Trusted People**, click OK, and complete the wizard.
8. Now you can double-click the `.msix` file and install it normally!

### Option B: Publishing to the Microsoft Store
If you publish your `.msix` file directly to the Microsoft Store via the Windows Partner Center, Microsoft will automatically sign the application for you. You don't need to buy a certificate for this method.

### Option C: Using a Paid Code Signing Certificate
If you want to distribute the app outside the Microsoft Store (e.g., via a website) and have it install seamlessly for all users without the manual steps in Option A, you must purchase a Code Signing Certificate from a trusted authority (like Sectigo, DigiCert, or SSL.com).

Once you have purchased a certificate (`.pfx` file), you can configure the msix package to use it by updating your `pubspec.yaml`:

```yaml
msix_config:
  # ... other configs ...
  certificate_path: C:\path\to\your\certificate.pfx
  certificate_password: your_certificate_password
```
When you run `dart run msix:create`, it will sign the app with your official certificate, allowing anyone to install it without warnings.
