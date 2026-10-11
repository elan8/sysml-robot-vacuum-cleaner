// Elan8 house template for the robot's engineering documents.
//
// One template serves all three documents: the kind of document shown on the cover is the
// `subtitle` of its `@Document` annotation. Start your own from `doc42 template export`.
#import "/engineering.typ": engineering-document
#engineering-document(json("/doc42.json"))
