import 'package:example/core/widgets/custom_refresh_indicator/liquid_pull_to_refresh.dart';
import 'package:example/features/devices/presentation/cubit/devices_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tuya_flutter_ha_sdk/models/thing_smart_home_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesCubit>().loadHomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout via AuthCubit
              context.go('/auth');
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: () => context.read<DevicesCubit>().loadHomes(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: BlocBuilder<DevicesCubit, DevicesState>(
            builder: (context, state) {
              final cubit = context.read<DevicesCubit>();
              if (state is HomesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final homes = cubit.currentHomes;
              if (homes == null || homes.isEmpty) {
                return const Center(child: Text('No homes found.'));
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...buildHomeCards(context.read<DevicesCubit>().currentHomes!),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add home dialog/sheet
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Add home coming soon')));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<Widget> buildHomeCards(List<ThingSmartHomeModel> homes) {
    return homes.map((home) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.read<DevicesCubit>().setHomeId(home.homeId!);
            context.pushNamed('devices');
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      home.name ?? 'Unnamed Home',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      home.homeStatus == HomeJoinStatus.accepted
                          ? Icons.home
                          : Icons.home_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
                Text(
                  'ID: ${home.homeId}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${home.geoName}  : ${home.lat}, ${home.lon}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
