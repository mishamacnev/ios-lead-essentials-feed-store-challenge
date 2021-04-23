
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedFeedCache

	var local: LocalFeedImage {
		LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
