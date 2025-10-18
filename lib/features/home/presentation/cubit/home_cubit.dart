import 'package:flutter_bloc/flutter_bloc.dart';

class HomeModel {
  final String id;
  final String name;
  final int deviceCount;

  HomeModel({required this.id, required this.name, required this.deviceCount});
}

class HomeCubit extends Cubit<List<HomeModel>> {
  HomeCubit()
    : super([
        // Stub data - replace with real Tuya SDK calls
        HomeModel(id: '1', name: 'My Home', deviceCount: 3),
        HomeModel(id: '2', name: 'Beach House', deviceCount: 2),
      ]);

  Future<void> loadHomes() async {
    // TODO: Call Tuya SDK to get homes
    // For now using stub data from constructor
  }

  Future<void> addHome(String name) async {
    // TODO: Call Tuya SDK to create home
    // For now just add to list
    final newHome = HomeModel(
      id: DateTime.now().toString(),
      name: name,
      deviceCount: 0,
    );
    emit([...state, newHome]);
  }
}
