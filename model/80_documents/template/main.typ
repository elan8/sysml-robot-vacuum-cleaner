// Elan8 house template for the robot's engineering documents.
//
// One template serves every document: the kind of document shown on the cover is the
// `subtitle` of its `@Document` annotation. All styling is in `elan8.typ`; the model and the
// document views carry none.
#import "/elan8.typ": elan8-document
#elan8-document(json("/doc42.json"))
