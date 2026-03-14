# CocoaPlayground

> ⚠️ **This repository is archived.** It is no longer actively maintained and is kept here for historical reference only.

A collection of small macOS desktop application experiments written in Objective-C, created in 2009. The projects demonstrate the use of Cocoa frameworks available on macOS at the time, including Address Book integration and system icon extraction.

## Projects

### ContactPics

A macOS application that retrieves and displays contact photos from the system Address Book.

**Features:**
- Displays contact photos using three different view modes:
  - Image browser view (`IKImageBrowserView`)
  - Flow view
  - Table view
- Search contacts by email prefix
- Full-screen viewing mode
- Contacts sorted by last name, then first name

**Frameworks used:** Cocoa, AddressBook, Quartz (Image Kit)

---

### ImageGrabber

A macOS utility that extracts system icons and saves them to disk.

**Features:**
- Grab an icon by specifying a file path
- Grab an icon by specifying a file type extension
- Save grabbed icons to disk in TIFF format

**Frameworks used:** Cocoa, AppKit (NSWorkspace)

---

## Requirements

- **Language:** Objective-C (pre-ARC)
- **Platform:** macOS
- **IDE:** Xcode (projects were created with Xcode around 2009)

> These projects target legacy macOS APIs (e.g., `ABAddressBook`, `IKImageBrowserView`) that may be deprecated or unavailable in modern versions of macOS and Xcode.

## License

Copyright © 2009 Lithoglyph Inc. All rights reserved.
