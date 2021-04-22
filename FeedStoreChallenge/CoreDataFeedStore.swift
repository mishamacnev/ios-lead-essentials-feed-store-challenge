//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform { [context] in
			let data = try! ManagedFeedCache.find(context: context)
			if let data = data {
				completion(.found(feed: data.local, timestamp: data.timestamp))
			} else {
				completion(.empty)
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [context] in
			do {
				let feedCache = ManagedFeedCache(context: context)
				feedCache.timestamp = timestamp
				feedCache.feed = self.map(feed, context: context)
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}

	private func map(_ images: [LocalFeedImage], context: NSManagedObjectContext) -> NSOrderedSet {
		let models = images.map { image -> ManagedFeedImage in
			let model = ManagedFeedImage(context: context)
			model.id = image.id
			model.imageDescription = image.description
			model.location = image.location
			model.url = image.url
			return model
		}

		return NSOrderedSet(array: models)
	}
}

@objc(ManagedFeedCache)
class ManagedFeedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	static func find(context: NSManagedObjectContext) throws -> ManagedFeedCache? {
		let request = NSFetchRequest<ManagedFeedCache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	var local: [LocalFeedImage] {
		feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
}

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL

	var local: LocalFeedImage {
		LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
