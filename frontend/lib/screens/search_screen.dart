import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/ec_service.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _sroController = TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(); // e.g. 2023

  bool _isLoading = false;

  void _performSearch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final ecService = Provider.of<ECService>(context, listen: false);

    try {
      final result = await ecService.startSearch(
        district: _districtController.text,
        sro: _sroController.text, // Normally a dropdown value
        docNumber: _docNumberController.text,
        year: _yearController.text,
      );
      
      final sessionId = result['sessionId'];

      if (!mounted) return;

      // Navigate to Results Screen (which involves waiting for CAPTCHA)
      // In a real flow, we might need an intermediate "Waiting for Captcha" screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(sessionId: sessionId),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.manage_search, size: 64, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    'EC Search & Diagram',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter document details to generate boundary diagrams instantly.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // District
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(labelText: 'District'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // SRO
                  TextFormField(
                    controller: _sroController,
                    decoration: const InputDecoration(labelText: 'SRO'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _docNumberController,
                          decoration: const InputDecoration(labelText: 'Doc Number'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(labelText: 'Year'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performSearch,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Start Search'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
