# Meet SwiftData

**WWDC23 · Session 10187 · ~9 min** · [Watch](https://developer.apple.com/videos/play/wwdc2023/10187/)
**Type:** New framework / new API

## TL;DR
- SwiftData is Apple's new Swift-native persistence framework — same Core Data storage engine underneath, but the schema is *your Swift code* (`@Model`) instead of a `.xcdatamodeld` file, and fetching uses type-checked `#Predicate` macros instead of `NSPredicate` strings.
- Affects anyone building new data-backed apps on iOS 17+ and anyone maintaining a Core Data app considering a migration. The headline benefit: declare your model once as a plain Swift class, get persistence, change tracking, undo, iCloud sync, and `@Query`-driven SwiftUI updates for free.
- The single most important takeaway: this is the new default persistence stack for SwiftUI apps. Three pieces do everything — `@Model` (schema), `ModelContainer`/`ModelContext` (storage + operations), `@Query` (SwiftUI binding).

**Should you care?** Yes if you're starting a new iOS 17+ app — reach for SwiftData over Core Data, it removes the entire model-editor + boilerplate layer. If you have a mature, shipping Core Data app on older OS targets, don't rush: SwiftData is iOS 17-only and this session is just the overview — watch "Migrate to SwiftData" before committing.
**Minimum target:** iOS 17 / iPadOS 17 / macOS 14 / tvOS 17 / watchOS 10 (predicate + macros are iOS 17-new, per the transcript)

## Why this exists

Core Data is powerful but bolts a non-Swift modeling layer onto a Swift codebase: a separate `.xcdatamodeld` editor, `NSManagedObject` subclasses, stringly-typed `NSPredicate`, and a lot of `NSManagedObjectContext` ceremony. SwiftData keeps Core Data's proven storage engine but makes the *schema the source of truth in Swift code* using the new macro system — no external file formats, no codegen step you don't control. The result is that an ordinary Swift class becomes a persisted, observed, query-able model with a single attribute, and it was designed alongside SwiftUI's new Observation feature so view updates are automatic.

## Key APIs

### `@Model`
Macro applied to a class; turns its stored properties into persisted properties and makes the class the schema source of truth. Available iOS 17.
```swift
import SwiftData

@Model
class Trip {
    var name: String
    var destination: String
    var endDate: Date
    var startDate: Date

    var bucketList: [BucketListItem]? = []      // to-many relationship
    var livingAccommodation: LivingAccommodation? // to-one relationship
}
```
Value-type properties (String, Int, Float, plus structs, enums, Codable types, and collections) become **attributes** automatically. Properties whose type is another `@Model` become **relationships**. `@Model` rewrites *all* stored properties, which is what lets the context track mutations transparently — you just use normal property setters. ([1:27](https://developer.apple.com/videos/play/wwdc2023/10187/?time=87))

### `@Attribute` / `@Relationship` / `@Transient`
Per-property metadata to influence schema generation. Available iOS 17.
```swift
@Model
class Trip {
    @Attribute(.unique) var name: String          // uniqueness constraint
    var destination: String
    var endDate: Date
    var startDate: Date

    @Relationship(.cascade) var bucketList: [BucketListItem]? = []
    var livingAccommodation: LivingAccommodation?
}
```
`@Attribute(.unique)` adds a uniqueness constraint. `@Relationship(.cascade)` controls inverse choice and delete-propagation — here, deleting a `Trip` deletes its bucket-list items. `@Transient` (mentioned, not shown) excludes a property from persistence. ([2:46](https://developer.apple.com/videos/play/wwdc2023/10187/?time=166))

### `ModelContainer`
The persistent backend for your model types. Available iOS 17.
```swift
// Schema only — default settings
let container = try ModelContainer(for: [Trip.self, LivingAccommodation.self])

// With configuration: custom URL, CloudKit / app-group identifiers, migration options
let container = try ModelContainer(
    for: [Trip.self, LivingAccommodation.self],
    configurations: ModelConfiguration(url: URL("path"))
)
```
You hand it the list of model types; `ModelConfiguration` is where store URL, CloudKit/group container IDs, and migration options live. ([3:43](https://developer.apple.com/videos/play/wwdc2023/10187/?time=223))

### `ModelContext`
Your interface for tracking changes, fetching, saving, and undo. Available iOS 17.
```swift
// CRUD
context.insert(myTrip)
context.delete(myTrip)
try context.save()
```
Contexts observe all model changes. In SwiftUI you usually pull one from the environment; outside the view hierarchy you can ask the container for its **main-actor-bound** shared context or instantiate new contexts yourself. ([6:15](https://developer.apple.com/videos/play/wwdc2023/10187/?time=375))

### `#Predicate`
Type-checked, macro-built replacement for `NSPredicate`. Works on native Swift types with autocomplete. Available iOS 17.
```swift
let today = Date()
let tripPredicate = #Predicate<Trip> {
    $0.destination == "New York" &&
    $0.name.contains("birthday") &&
    $0.startDate > today
}
```
Fully type-checked at compile time — no more stringly-typed format strings or runtime key-path typos. ([5:13](https://developer.apple.com/videos/play/wwdc2023/10187/?time=313))

### `FetchDescriptor` + `SortDescriptor`
The fetch query object, combining predicate + sort (now keypath/native-type aware). Available iOS 17.
```swift
let descriptor = FetchDescriptor<Trip>(
    sortBy: [SortDescriptor(\Trip.name)],
    predicate: tripPredicate
)
let trips = try context.fetch(descriptor)
```
`FetchDescriptor` also supports prefetching related objects, result-count limits, and excluding unsaved changes. `SortDescriptor` was upgraded to take Swift keypaths directly. ([5:32](https://developer.apple.com/videos/play/wwdc2023/10187/?time=332), [5:46](https://developer.apple.com/videos/play/wwdc2023/10187/?time=346))

> Note: the transcript's slide shows `sortBy: SortDescriptor(...)`. The `sortBy:` parameter is an array (`[SortDescriptor<Trip>]`); the demo below uses the array form, which is the correct API shape.

### `.modelContainer(for:)` + `@Query` (SwiftUI integration)
Scene/view modifier to install the container; property wrapper to fetch + observe. Available iOS 17.
```swift
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
        .modelContainer(for: [Trip.self, LivingAccommodation.self])
    }
}

struct ContentView: View {
    @Query(sort: \.startDate, order: .reverse) var trips: [Trip]
    @Environment(\.modelContext) var modelContext
    // ...
}
```
`.modelContainer(for:)` builds the container and injects a `ModelContext` into the environment. `@Query` loads + filters + sorts in one line and — because `@Model` types participate in the new Observation feature — the view refreshes automatically when observed properties change. ([3:58](https://developer.apple.com/videos/play/wwdc2023/10187/?time=238), [4:20](https://developer.apple.com/videos/play/wwdc2023/10187/?time=260), [7:38](https://developer.apple.com/videos/play/wwdc2023/10187/?time=458))

## How the pieces fit

1. Decorate model classes with `@Model`; refine with `@Attribute`/`@Relationship`/`@Transient`.
2. At the app/scene level, install storage with `.modelContainer(for:)` — this also puts a `ModelContext` in the environment.
3. In a view, declare data with `@Query` (auto-fetches, auto-updates) and grab `@Environment(\.modelContext)` for writes.
4. Mutate via `context.insert` / `context.delete` / plain property setters; `context.save()` commits (autosave is on by default through the SwiftUI integration).
5. Outside SwiftUI, build a `ModelContainer` yourself and use its main-actor context or a fresh `ModelContext`.

## Gotchas
- **iOS 17+ only.** `@Model`, `#Predicate`, and the macro machinery are all new in iOS 17 — no back-deployment. If you support older OS versions you can't adopt yet.
- **Concurrency / actor boundary.** The container vends a *main-actor-bound* shared context. SwiftData model objects are not freely `Sendable` across arbitrary threads — treat a `ModelContext` and its objects as bound to their actor, and create separate contexts for background work (this overview doesn't detail it; see "Dive deeper into SwiftData").
- **Relationships need an optional or default.** The samples declare to-many as `[BucketListItem]? = []` and to-one as optional — model relationships so the schema can be generated and objects can exist before links are set.
- **`@Model` rewrites every stored property.** That's how transparent change tracking works, but it means computed properties and anything you don't want persisted must be handled deliberately (`@Transient`).
- **`sortBy:` is an array.** The on-slide single-descriptor form is shorthand; the parameter type is `[SortDescriptor<T>]`.
- **Same store engine as Core Data.** Coexistence/migration with an existing Core Data stack is possible but is its own topic — don't assume drop-in interop without watching the migration session.

## Try it
See `Demo.swift` — a complete, single-file SwiftUI app: two `@Model` types with a cascade relationship and a unique constraint, a `.modelContainer` install, a `@Query`-driven list, and insert/delete/save through the environment's `ModelContext`. Paste into a new iOS 17 app target and run.

## Go deeper
- [Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195) — `@Attribute`/`@Relationship` in depth
- [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196) — containers, contexts, concurrency, the fetch pipeline
- [Build an app with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10154) — full SwiftUI integration walkthrough
- [Migrate to SwiftData](https://developer.apple.com/videos/play/wwdc2023/10189) — for existing Core Data apps
- [Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149) — the mechanism behind `@Query` auto-updates
- Docs: [SwiftData](https://developer.apple.com/documentation/SwiftData) · [Adopting SwiftData for a Core Data app](https://developer.apple.com/documentation/CoreData/adopting-swiftdata-for-a-core-data-app)
