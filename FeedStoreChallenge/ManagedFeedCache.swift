
import CoreData

@objc(ManagedFeedCache)
final class ManagedFeedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	static func find(context: NSManagedObjectContext) throws -> ManagedFeedCache? {
		let request = NSFetchRequest<ManagedFeedCache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	static func getUniqueInstance(context: NSManagedObjectContext) throws -> ManagedFeedCache {
		try find(context: context).map(context.delete)
		return ManagedFeedCache(context: context)
	}

	static func delete(context: NSManagedObjectContext) throws {
		try find(context: context).map(context.delete)
	}

	static func map(_ images: [LocalFeedImage], context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: images.map { image in
			let model = ManagedFeedImage(context: context)
			model.id = image.id
			model.imageDescription = image.description
			model.location = image.location
			model.url = image.url
			return model
		})
	}

	var local: [LocalFeedImage] {
		feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
}
