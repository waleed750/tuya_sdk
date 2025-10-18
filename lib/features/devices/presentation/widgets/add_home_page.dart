import 'dart:developer';

import 'package:example/core/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/devices_cubit.dart';
import 'site_map_widget.dart';

class AddHomePage extends StatefulWidget {
  const AddHomePage({super.key});

  @override
  State<AddHomePage> createState() => _AddHomePageState();
}

class _AddHomePageState extends State<AddHomePage> {
  late final TextEditingController _homeNameController;
  late final TextEditingController _addressController;
  double latitude = 0.0;
  double longitude = 0.0;
  late final GlobalKey<FormState> _formKey;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _homeNameController = TextEditingController();
    _addressController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Home')),
      body: SafeArea(
        child: BlocListener<DevicesCubit, DevicesState>(
          listener: (context, state) {
            if (state is HomeAdded) {
              Navigator.of(context).pop();
            } else if (state is DevicesError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  spacing: 10,
                  children: [
                    TextFormField(
                      controller: _homeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Home Name',
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        // Handle home name input
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        // Handle address input
                      },
                    ),
                    Text(
                      'Select Home Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: SiteMapWidget(
                        onChanged: (latLng, label) {
                          log('Selected location: $label at $latLng');
                          latitude = latLng.latitude;
                          longitude = latLng.longitude;
                          setState(() {});
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle add home action
                        if (_formKey.currentState!.validate()) {
                          final homeName = _homeNameController.text;
                          final address = _addressController.text;
                          LoaderWidget.show(
                            context,
                            () => context.read<DevicesCubit>().addNewHome(
                              name: homeName,
                              address: address,
                              latitude: latitude,
                              longitude: longitude,
                            ),
                          );
                          // Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
