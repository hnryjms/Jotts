# Jotts

Jotts helps students stay organized for class.

## Getting Started

This project is designed to run in Xcode 11 with any system configuration. It
uses SwiftUI and Code Data to manage data and UI.

## Common Tasks

Regenerating the `Base.lproj/Localizable.strings` file:

```bash
cd iOS
find . -name "*.swift" | xargs genstrings -SwiftUI -o Base.lproj
```

## Contributing

To make contributions to Jotts, follow the steps below to help students organize
their classes and schoolwork, and enjoy an easier day in school.

1. Fork the `hnryjms/Jotts` repo
1. Commit changes to your fork
1. Create a pull request back into this repo
1. Win

Make sure to run & write tests for new features.
