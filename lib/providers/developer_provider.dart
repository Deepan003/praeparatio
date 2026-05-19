import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/developer_info_model.dart';
import '../services/supabase_service.dart';

final developerInfoProvider = StreamProvider<DeveloperInfoModel>((ref) async* {
  await for (final data in SupabaseService.instance.streamDeveloperInfo()) {
    if (data == null) {
      yield DeveloperInfoModel(
        isEnabled: false,
        name: 'Deepan Pramanick',
        showAvatar: true,
        links: [],
      );
    } else {
      yield DeveloperInfoModel.fromJson(data);
    }
  }
});
