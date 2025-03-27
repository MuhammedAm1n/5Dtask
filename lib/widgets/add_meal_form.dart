import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/meal.dart';
import 'dart:io';

class AddMealForm extends StatefulWidget {
  final Function(Meal) onMealAdded;

  const AddMealForm({super.key, required this.onMealAdded});

  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String? _photoPath;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _photoPath = image.path;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Camera permission is required to take photos')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to access camera')),
        );
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        id: const Uuid().v4(),
        name: _nameController.text,
        calories: int.parse(_caloriesController.text),
        time: DateTime.now(),
        photoPath: _photoPath,
      );
      widget.onMealAdded(meal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Meal Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a meal name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _caloriesController,
            decoration: const InputDecoration(labelText: 'Calories'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter calories';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
          if (_photoPath != null) ...[
            const SizedBox(height: 8),
            Image.file(
              File(_photoPath!),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Add Meal'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
