# VisualExif 🛡️

A native macOS application for professional metadata management, folder-level batch processing, and selective tag removal. Part of the **Single Use Apps** collection.

## The Concept

In an era where every photo carries hidden data — GPS coordinates, device fingerprints, personal timestamps — **VisualExif** gives you surgical control over what you share. Drag a file. Inspect its secrets. Neutralize what you don't want. Simple.

## Current Features (v1.1.0)

- **Real-time Metadata Inspector** — Instant visualization of all metadata tags upon drag & drop.
- **Selective Tag Removal** — Choose specific categories (GPS, EXIF, IPTC, XMP, MakerNotes) to remove.
- **Folder Batch Processing** — Scan an entire directory and process all supported files at once.
- **Bundled ExifTool Engine** — No external dependencies. The industry-standard ExifTool v13.57 is embedded directly in the app.
- **Progress Tracking** — Real-time progress bar during batch operations.

## Roadmap

### 🆓 Free Tier

1. **Drag & Drop Interface** — Intuitive drag & drop for single files and folders. ✅ *Implemented*
2. **Real-time Metadata Inspector** — Scrollable side panel showing all parameters and values immediately upon file drop. ✅ *Implemented*
3. **Remove All Metadata** — One-click removal of every metadata tag from a single file.
4. **Remove GPS Only** — Strip location data while preserving all other metadata.
5. **Core Format Support** — JPG, JPEG, PNG, HEIC, TIFF, MOV, MP4, M4V.

---

### 💎 PRO Tier

6. **Unlimited Batch Processing** — Process entire folder hierarchies with thousands of files simultaneously.
7. **Selective Tag Removal** — Granular control over exactly which metadata categories to neutralize (GPS, EXIF, IPTC, XMP, MakerNotes). ✅ *Implemented*
8. **Metadata Export** — Export a full metadata report (CSV or JSON) before cleaning, for archival or compliance purposes.
9. **Before / After Comparison** — Side-by-side view of metadata state before and after neutralization.
10. **Preset Profiles** — Save and apply custom removal profiles (e.g. "Social Media Safe", "Press Release", "Client Delivery").
11. **Rename by Metadata** — Bulk-rename files using embedded metadata fields such as capture date, camera model, or GPS region.
12. **Watch Folder** — Monitor a designated folder and automatically clean new files as they arrive.
13. **RAW Format Support** — Full support for professional camera formats: CR2, CR3, ARW, NEF, ORF, DNG.
14. **Date Fixer** — Synchronize file system creation/modification dates with the actual capture timestamp stored in metadata.
15. **Operation History & Undo** — Full log of all operations with the ability to revert changes using backed-up originals.

---

## Pricing

| Tier | Price | License |
|------|-------|---------|
| **Free** | €0 | Unlimited, no expiry |
| **PRO** | €9.99 | One-time lifetime purchase |

Licenses are distributed via the [Single Use Apps Portal](http://singleuseapps.epizy.com). No subscriptions. Ever.

## Architecture

- **Language**: Swift 5.0
- **Framework**: SwiftUI
- **Metadata Engine**: ExifTool v13.57 (bundled)
- **Deployment Target**: macOS 14.0+

## Installation

1. Download the latest `VisualExif.zip` from the [Releases](https://github.com/luisdanielsilva/VisualExif/releases) page.
2. Unzip and move `VisualExif.app` to your `/Applications` folder.
3. Open the app and start inspecting.

## Licensing

This application is part of the **Single Use Apps** collection. A lifetime PRO license can be generated via the [Single Use Apps Portal](http://singleuseapps.epizy.com).

---
Proudly developed in Porto, Portugal. 🇵🇹
