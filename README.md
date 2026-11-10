<p align="center">
  <img src="InSeconds/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="180" alt="InSeconds app icon">
</p>

<h1 align="center">InSeconds</h1>

A single-screen SwiftUI prototype of a short-form, vertically paged video feed (Reels/TikTok style).
Only the visible video plays; others are paused or released. Includes play/pause, loading and error states,
and background handling.

---

## App screenshot
<img width="200" height="400" alt="Screenshot iPhone 18 Pro 10-11-2026 at 7 59 59 PM" src="https://github.com/user-attachments/assets/fa298500-d067-4a1d-bb68-9edb938c24f5" />
<img width="200" height="400" alt="Screenshot iPhone 18 Pro 10-11-2026 at 8 00 30 PM" src="https://github.com/user-attachments/assets/a927a066-ca2a-4df9-95ac-4ab6c57e89f6" />
<img width="200" height="400" alt="Screenshot iPhone 18 Pro 10-11-2026 at 8 00 07 PM" src="https://github.com/user-attachments/assets/196d1035-ff3d-4fac-89db-1f4876926912" />

## Memory screenshot
<img width="250" height="200" alt="Screenshot 2026-11-10 at 8 03 18 PM" src="https://github.com/user-attachments/assets/9bd2d1b5-aba5-4c8e-ac56-a7a7d9b3295b" />
<img width="250" height="200" alt="Screenshot 2026-11-10 at 8 03 02 PM" src="https://github.com/user-attachments/assets/e1e4889f-744f-4ae6-9f4b-779a5016b5ea" />
<img width="250" height="200" alt="Screenshot 2026-11-10 at 8 02 48 PM" src="https://github.com/user-attachments/assets/668650a0-02f7-4e51-b50b-2d6466f0d3bb" />
<img width="250" height="200" alt="Screenshot 2026-11-10 at 8 02 30 PM" src="https://github.com/user-attachments/assets/9b148495-438c-4107-afb8-fd2ca10f42e9" />

## Setup & run

1. Open `InSeconds.xcodeproj` in **Xcode 27.2+** (the project was created with Xcode 27.2 and uses its
   newer project file format; the app itself targets iOS 17.6+).
2. Select the **InSeconds** scheme and an **iPhone 18 Pro** simulator (any iOS 17+ iPhone works).
3. Press **⌘R**. An internet connection is required (videos are streamed).

No third-party libraries, no setup steps. Debug builds print `[Feed]` / `[Player]` lifecycle logs to the
console (player created, released, `deinit`, etc.); Release builds compile these out (`#if DEBUG`).

## Engineering note

**1. Structure — MVVM with small components.**
`Models/` (`VideoItem`), `Data/` (sample items), `ViewModels/` (`FeedViewModel`, `PlayerViewModel`),
`Views/` (`FeedView`, `VideoPageView`) and `Views/Components/` (header, page dots, info, progress bar,
pause overlay, loading, error, player layer), plus `Theme/AppTheme`. All playback logic lives in view models,
so views only render state. Small components keep each file easy to read and change. I avoided protocols,
DI containers and coordinators on purpose — for one screen they would add indirection without benefit.
View models use iOS 17's `@Observable`, so a view only redraws when a property it reads changes.

**2. Only the active video plays.**
The feed is a `ScrollView` + `LazyVStack` with `.scrollTargetBehavior(.paging)`, and
`.scrollPosition(id:)` is bound to `FeedViewModel.activeItemID`. When it changes, `updatePlayers()`
first pauses every non-active player, then plays the active one — so two videos can never overlap.
The scene phase is forwarded from the App: on `.inactive`/`.background` the active video pauses; on
`.active` it resumes only if the user hadn't paused it manually.

**3. AVPlayer instances, observers and memory.**
- **Window of 3:** players exist only for `activeIndex - 1`, `activeIndex`, `activeIndex + 1`. Anything
  outside is cleaned up and removed, so memory stays flat however long the feed is.
- **Lazy + preload:** the `AVPlayer` is created only when a page enters the window. The next video starts
  loading paused, so swiping feels instant.
- **Bounded buffering:** `preferredForwardBufferDuration = 5` and `automaticallyWaitsToMinimizeStalling = true`.
- **`cleanup()`** pauses → removes the periodic time observer (stored token) → invalidates the KVO
  observations (`status`, `timeControlStatus`) → removes the end-of-video NotificationCenter observer →
  `replaceCurrentItem(with: nil)` and releases the player. `deinit` also removes observers as a safety net.
- **No retain cycles:** every observer closure captures `[weak self]`; KVO callbacks hop to the main actor.
- The time observer fires every 0.25 s (smooth enough, cheap). `PlayerLayerView` only reassigns
  `layer.player` when it actually changes, and drops it in `dismantleUIView`.
- **Why UIKit:** SwiftUI's `VideoPlayer` adds system controls and hides the layer, so `PlayerLayerView`
  wraps a `UIView` whose `layerClass` is `AVPlayerLayer` (with `.resizeAspectFill`).

**4. Before production I would add:** a disk cache / `AVAssetResourceLoader` for downloaded segments;
HLS (adaptive bitrate) instead of progressive MP4; tuning the prefetch window from real network data;
retry with exponential backoff and offline detection; analytics (start time, stalls, completion);
unit tests for `FeedViewModel`/`PlayerViewModel` (window logic, state transitions); a full accessibility
review (VoiceOver, Dynamic Type); and structured logging (`os.Logger`) instead of `print`.

**5. Left out because of the 2–3 hour limit:** likes/comments/connect actions, tab bar and navigation,
backend/API and pagination, offline caching.

## Known limitations & assumptions

- Sample videos are landscape (16:9), so `aspectFill` crops them on a portrait screen.
- Requires network; there is no offline cache, so revisiting a released page re-downloads it.
- Google's public sample bucket (`gtv-videos-bucket`) now returns **403 Access Denied**, so I used other
  public clips (see Sources). Item 4 uses an intentionally broken URL to demo the error state.
- "Skip to next" on the last item wraps to the first item.
- Header shows the logo only — the page counter was removed in the final design; page position is shown
  by the dots on the right.

## Sources

- Apple Developer Documentation — AVFoundation (`AVPlayer`, `AVPlayerItem`, `AVPlayerLayer`, `AVAudioSession`)
  and SwiftUI (`scrollPosition`, `scrollTargetBehavior`, `containerRelativeFrame`).
- Sample videos: MDN CC0 videos (`flower.mp4`, `friday.mp4`, interactive-examples.mdn.mozilla.net) and
  *Big Buck Bunny* © Blender Foundation, CC BY 3.0 (via test-videos.co.uk).
