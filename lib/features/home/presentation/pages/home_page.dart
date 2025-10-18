import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Home'),
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
      body: BlocBuilder<HomeCubit, List<HomeModel>>(
        builder: (context, homes) {
          if (homes.isEmpty) {
            return Center(child: Text('No homes yet. Tap + to add one.'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: homes.length,
            separatorBuilder: (_, _) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final home = homes[index];
              return _HomeCard(
                name: home.name,
                deviceCount: home.deviceCount,
                onTap: () => context.push('/devices'),
              );
            },
          );
        },
      ),
     
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String name;
  final int deviceCount;
  final VoidCallback onTap;

  const _HomeCard({
    required this.name,
    required this.deviceCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Text(
                '$deviceCount devices',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
