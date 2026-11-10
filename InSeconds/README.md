# InSeconds — Vertical Video Feed (iOS prototype)

A single-screen SwiftUI prototype of a short-form, vertically paged video feed (Reels/TikTok style).
Only the visible video plays; others are paused or released. Includes play/pause, loading and error states,
and background handling.

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

## Known limitations & assumptions

- Sample videos are landscape (16:9), so `aspectFill` crops them on a portrait screen.
- Requires network; there is no offline cache, so revisiting a released page re-downloads it.
- Google's public sample bucket (`gtv-videos-bucket`) now returns **403 Access Denied**, so I used other
  public clips (see Sources). Item 4 uses an intentionally broken URL to demo the error state.
- "Skip to next" on the last item wraps to the first item.
- Header shows the logo only — the page counter was removed in the final design; page position is shown
  by the dots on the right.
- iPhone is locked to portrait. Tested on the iOS simulator only, not on a physical device.

## Sources

- Apple Developer Documentation — AVFoundation (`AVPlayer`, `AVPlayerItem`, `AVPlayerLayer`, `AVAudioSession`)
  and SwiftUI (`scrollPosition`, `scrollTargetBehavior`, `containerRelativeFrame`).
- Sample videos: MDN CC0 videos (`flower.mp4`, `friday.mp4`, interactive-examples.mdn.mozilla.net) and
  *Big Buck Bunny* © Blender Foundation, CC BY 3.0 (via test-videos.co.uk).
