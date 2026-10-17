import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/category.dart';
import 'models/tag.dart';
import 'services/api.dart';

final apiProvider = Provider((_) => Api());

final loggedInProvider = FutureProvider<bool>(
  (ref) => ref.watch(apiProvider).hasToken(),
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(apiProvider).fetchCategories(),
);

final tagsProvider = FutureProvider<List<Tag>>(
  (ref) => ref.watch(apiProvider).fetchTags(),
);

final userNameProvider = FutureProvider<String>((ref) {
  ref.watch(loggedInProvider); // reloads after login or logout
  return ref.watch(apiProvider).fetchUserName();
});