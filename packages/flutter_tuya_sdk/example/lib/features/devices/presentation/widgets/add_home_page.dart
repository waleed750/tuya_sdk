import 'package:flutter_tuya_sdk_example/core/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/devices_cubit.dart';

class AddHomePage extends StatefulWidget {
  const AddHomePage({super.key});

  @override
  State<AddHomePage> createState() => _AddHomePageState();
}

class _AddHomePageState extends State<AddHomePage> {
  late final TextEditingController _homeNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final GlobalKey<FormState> _formKey;
  @override
  void initState() {
    super.initState();
    _homeNameController = TextEditingController();
    _addressController = TextEditingController();
    _latController = TextEditingController(text: '0.0');
    _lngController = TextEditingController(text: '0.0');
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _homeNameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
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
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    Text(
                      'Home Location (optional)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        contentPadding: EdgeInsets.all(16),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                    TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        contentPadding: EdgeInsets.all(16),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final homeName = _homeNameController.text;
                          final address = _addressController.text;
                          final lat = double.tryParse(_latController.text) ?? 0.0;
                          final lng = double.tryParse(_lngController.text) ?? 0.0;
                          LoaderWidget.show(
                            context,
                            () => context.read<DevicesCubit>().addNewHome(
                              name: homeName,
                              address: address,
                              latitude: lat,
                              longitude: lng,
                            ),
                          );
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
