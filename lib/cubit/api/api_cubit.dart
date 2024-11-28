import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/mattermost_api.dart';

class ApiCubit extends Cubit<MattermostApi> {
  ApiCubit() : super(MattermostApi());

  MattermostApi get api => state;
}
