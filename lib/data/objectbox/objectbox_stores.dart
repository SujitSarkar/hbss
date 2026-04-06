import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:maori_health/objectbox.g.dart';

/// Two ObjectBox [Store]s: [localStorageStore] (`cache_db`) and [offlineStore] (`offline_db`).
class ObjectBoxStores {
  ObjectBoxStores({required this.localStorageStore, required this.offlineStore});

  final Store localStorageStore;
  final Store offlineStore;

  static Future<ObjectBoxStores> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final localStorage = await openStore(directory: p.join(dir.path, 'cache_db'));
    final offline = await openStore(directory: p.join(dir.path, 'offline_db'));
    return ObjectBoxStores(localStorageStore: localStorage, offlineStore: offline);
  }

  void close() {
    localStorageStore.close();
    offlineStore.close();
  }
}
