# CodingChallenge-500px
The objective of this coding challenge is to create a simple photo-browsing app using [500px's APIs](https://github.com/500px/legacy-api-documentation). The deliverable should fulfill a minimal set of requirements as outlined below:
* __Photo Showcase__
  
  The app should showcase Popular photos from 500px dynamically obtained from the 500px API.<br/>
  Futhermore, the showcase should allow app users to browse through multiple pages of content.
  
* __Photo Details__

  When a user clicks on showcased photo, a full screen version of the photo should be displayed along with detailed information about the photo.

The engineering team at 500px works with [IGListKit](https://github.com/Instagram/IGListKit), [RocketData](https://github.com/plivesey/RocketData) and [Alamofire](https://github.com/Alamofire/Alamofire) on a day-to-day basis to deliver performant & reliable products. My attempt at this challenge will be to recreate a simplified version of [500px](https://apps.apple.com/app/500px/id471965292) using their native counterparts - [UICollectionView](https://developer.apple.com/documentation/uikit/uicollectionview), [CoreData](https://developer.apple.com/documentation/coredata), and [URLSession](https://developer.apple.com/documentation/foundation/urlsession).

## The Demo
![Demo](./Demo/500pxDemo.gif)

## TODO
* __Justified Layout - Showcasing Photos with Preserved Aspect Ratios__

   A classic approach to justifying layout of a photo grid to display photos in their aspect ratios finds its roots in the [Text Justification](https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap) problem. The idea is to have photo dimensions resized to fit fixed row heights while preserving aspect ratios. Photo failing to stack to the end of the row is moved to the next row. 
   
   The drawback with this approach is that it introduces either uneven inter-item spacings or inconsistent margins at the end of each row, depending on the fitting policy. With somewhat flexible row heights, inter-item spacing can be strictly enforced to give a more consistent look. 
   
   500px's own [Greedo Layout](https://github.com/500px/greedo-layout-for-ios) is an elegant take on the idea. Nevertheless, the tough grind with justified layout implementations is adapting to device orientation transitions.

## Instruction
Create file __"consumer_key.txt"__ with 500px's consumer key in the Xcode project.

## Design
![Design](./Design/500pxDesign.png)

### Data Source

__Fetching Remote Data__

[Request](./CodingChallenge-500px/Networking/Request.swift) is a lightweight web service client - a simple wrapper around [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) & [URLComponents](https://developer.apple.com/documentation/foundation/urlcomponents) coupled with its own builder designed to fullfil a subset of 500px's HTTP GET requests. It supports query parameter injection through the [ResourceParameter](./CodingChallenge-500px/Networking/ResourceParameter/ResourceParameter%2BPhotos.swift) abstraction.

__Handling Fetched Data__

Response from the request are de-serialized into CoreData entities using [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder). Data models are managed objects subclasses conforming to the [Decodable](https://developer.apple.com/documentation/swift/decodable) protocol. Entities are created and added to the background managed object context attached to the JSONDecoder via its [userInfo dictionary](https://developer.apple.com/documentation/foundation/jsondecoder/2895340-userinfo).

__CoreData__

* __Why CoreData?__

  Or more specifically, why use [CoreData](https://developer.apple.com/documentation/coredata) with SQLLite as its persistent store type as opposed to using CoreData simply for its in-memory object graph? Keeping managed objects and their relationships in memory is bound to overrun the heap at some point as the number of objects grow. So the idea is to have objects backed in the persistent store and faulted into memory as needed.

* __Managed Object Context Relationships__

  The decision is to forgo the typical parent-child relationship between managed object contexts. The reason being that the managed object model is setup to use the __id__ property of each [Photo](./CodingChallenge-500px/CoreData/DataModels/Photo%2BCoreDataClass.swift)/[User](CodingChallenge-500px/CoreData/DataModels/User%2BCoreDataClass.swift) entity as the primary key (and the [merge policy](https://developer.apple.com/documentation/coredata/nsmergepolicy/merge_policies) on relevant managed object contexts set to ` NSMergeByPropertyObjectTrumpMergePolicy`) so to avoid duplicates.
  
  Uniqueness constraint validation in CoreData relies on [NSPersistentStoreCoordinator](https://developer.apple.com/documentation/coredata/nspersistentstorecoordinator) working along-side [NSManagedObjectModel](https://developer.apple.com/documentation/coredata/nsmanagedobjectmodel) to do the heavy-lifting, so changes propagated between managed object contexts through parent-child relationships will also bring along unresolved duplications. Thus the decision is to have each managed object context wired to the persistent store coordinator as its parent store, and propagate changes with saves.

__ImageCache__

Loading images from remote is expensive, naturally a local copy of images fetched should be kept. Databases are not ideal for storing BLOBs, thus [ImageCache](./CodingChallenge-500px/ImageCache/ImageCache.swift) exists to fulfill this purpose - to fetch images through remote urls as required and store them locally in the application's caches directory.

[PersistentStore](./CodingChallenge-500px/PersistentStore/PersistentStore.swift) is used by the [ImageCache](./CodingChallenge-500px/ImageCache/ImageCache.swift) to persist & retrieve images from the local store. It implements two-level caching, using [NSCache](https://developer.apple.com/documentation/foundation/nscache) as an intermediate and resorting to disk only on cache miss. Operations on the [PersistentStore](./CodingChallenge-500px/PersistentStore/PersistentStore.swift) are controlled through an designated [dispatch queue](https://developer.apple.com/documentation/dispatch/dispatchqueue), allowing for concurrent reads while enforcing exclusive writes.

### Presentation

__The PhotoGrid__

  [ShowcaseViewController](./CodingChallenge-500px/ViewControllers/Showcase/ShowcaseViewController.swift) pulls remote data through its [DataProvider](./CodingChallenge-500px/ViewControllers/Showcase/DataProvider/ShowcaseViewController%2BDataProvider.swift), and uses [NSFetchedResultsController](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller) together with [UICollectionView](https://developer.apple.com/documentation/uikit/uicollectionview) and [UICollectionViewDataSource](https://developer.apple.com/documentation/uikit/uicollectionviewdatasource) to bridge fetched data with the user interface. Conforming to [NSFetchedResultsControllerDelegate](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller#1661441) brings data source changes to the user interface.

__Infinite Scroll__

  Infinite scroll is accomplished through [UICollectionViewDataSourcePrefetching](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching).
  
__Presenting Photo Details__

  Photo details are presented by [DetailViewController](./CodingChallenge-500px/ViewControllers/Detail/DetailViewController.swift). This view controller is presented modally by [ShowcaseViewController](./CodingChallenge-500px/ViewControllers/Showcase/ShowcaseViewController.swift) inside a [UIPageViewController](https://developer.apple.com/documentation/uikit/uipageviewcontroller). Navigation between detail views is possible by having [ShowcaseViewController](./CodingChallenge-500px/ViewControllers/Showcase/ShowcaseViewController.swift) conform to [UIPageViewControllerDataSource](https://developer.apple.com/documentation/uikit/uipageviewcontrollerdatasource).


## Author

Hsuan-Chih Chuang, <hsuanchih.chuang@gmail.com>
