// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:teacher/model/lunch_menu.dart';

// final lunchCollectionProvider =Provider<CollectionReference>(
//   (ref) => FirebaseFirestore.instanceFor(
//     app: Firebase.app(),
//     databaseId: 'atti'
//   ).collection('lunch_menu')
// );

// //실시간 메뉴 
// final lunchmenuListProvider =  StreamProvider<List<LunchMenu>>((ref) {
//   final col =ref.watch(lunchCollectionProvider);
//   return col.snapshots().map((snapshot){
//     return snapshot.docs
//                     .map((doc)=>LunchMenu.fromMap(doc.data() as Map<String,dynamic>,doc.id)).toList();
//   });
 

// });
// class LunchMenuActionNotifier extends Notifier<void>{

//   @override
//   void build() {
//   }
//   }

// final timetableActionProvider =NotifierProvider<LunchMenuActionNotifier,void>(
//   LunchMenuActionNotifier.new
// );