import 'package:example/core/widgets/custom_refresh_indicator/liquid_pull_to_refresh.dart';
import 'package:example/features/devices/presentation/cubit/devices_cubit.dart';
import 'package:example/features/devices/presentation/pages/devices_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    cubit.currentHomes?.map((home) {
                      return InkWell(
                        onTap: () {
                          cubit.setHomeId(home.homeId!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DevicesListPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              //Geo location
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
                      );
                    }).toList() ??
                    [const Text('No devices found.')],
              );
            },
          ),
        ),
      ),
    );
  }
}
