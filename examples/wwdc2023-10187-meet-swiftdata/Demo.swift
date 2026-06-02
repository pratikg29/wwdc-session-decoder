// Demo: Meet SwiftData (WWDC23, Session 10187)
// Runs as: SwiftUI App — paste into a new iOS 17+ App target (replace the generated App file).
// Requires: iOS 17 / iPadOS 17 / macOS 14, Xcode 15+, Swift 5.9 (for macros).
// NOTE: Not compiled in this environment — paste into Xcode to build and run.
//
// What it shows end-to-end:
//   - @Model schema (Trip + BucketListItem) with @Attribute(.unique) and @Relationship(.cascade)
//   - .modelContainer(for:) installing storage and injecting a ModelContext into the environment
//   - @Query auto-fetching + auto-sorting, with the view refreshing via Observation
//   - insert / delete / save through the environment's ModelContext
//   - a #Predicate + FetchDescriptor manual fetch

import SwiftUI
import SwiftData

// MARK: - Schema

@Model
final class Trip {
    // Uniqueness constraint: two trips can't share a name.
    @Attribute(.unique) var name: String
    var destination: String
    var startDate: Date
    var endDate: Date

    // Cascade delete: removing a Trip removes its bucket-list items.
    // To-many relationships are declared optional with a default so the
    // schema can be generated and the object can exist before links are set.
    @Relationship(.cascade) var bucketList: [BucketListItem]? = []

    init(name: String, destination: String, startDate: Date = .now, endDate: Date = .now) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
    }
}

@Model
final class BucketListItem {
    var title: String
    var isDone: Bool

    init(title: String, isDone: Bool = false) {
        self.title = title
        self.isDone = isDone
    }
}

// MARK: - View

struct ContentView: View {
    // @Query loads, sorts, and observes in one line. Newest trips first.
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]

    // The ModelContext injected by .modelContainer(for:) — used for writes.
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                ForEach(trips) { trip in
                    VStack(alignment: .leading) {
                        Text(trip.name).font(.headline)
                        Text(trip.destination).foregroundStyle(.secondary)
                        // Relationship access is just a property read.
                        Text("\(trip.bucketList?.count ?? 0) bucket-list items")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                // Swipe-to-delete: mark for deletion on the context.
                // Cascade rule deletes the related BucketListItems automatically.
                .onDelete { offsets in
                    for index in offsets { context.delete(trips[index]) }
                }
            }
            .navigationTitle("Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus", action: addSampleTrip)
                }
            }
        }
    }

    private func addSampleTrip() {
        let trip = Trip(
            name: "Birthday Trip \(Int.random(in: 1...9999))",
            destination: "New York",
            startDate: .now.addingTimeInterval(60 * 60 * 24 * 7) // a week out
        )
        trip.bucketList = [
            BucketListItem(title: "See a Broadway show"),
            BucketListItem(title: "Walk the High Line")
        ]
        // Insert begins change tracking. With the SwiftUI integration autosave
        // is on by default; context.save() shown below is how you'd commit manually.
        context.insert(trip)
        try? context.save()
    }
}

// MARK: - Example of a manual fetch with #Predicate + FetchDescriptor
// (Not wired into the UI — illustrates the type-checked query path from the session.)

func upcomingNewYorkBirthdayTrips(in context: ModelContext) throws -> [Trip] {
    let today = Date()
    let predicate = #Predicate<Trip> { trip in
        trip.destination == "New York" &&
        trip.name.contains("Birthday") &&
        trip.startDate > today
    }
    let descriptor = FetchDescriptor<Trip>(
        predicate: predicate,
        sortBy: [SortDescriptor(\Trip.startDate)]
    )
    return try context.fetch(descriptor)
}

// MARK: - Wiring (App entry point) so it actually runs

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Builds the ModelContainer for these types and injects a ModelContext
        // into the environment for every view in the scene.
        .modelContainer(for: [Trip.self, BucketListItem.self])
    }
}
