import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/ec_service.dart';
import '../services/location_service.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final LocationService _locationService = LocationService();
  List<District> _districts = [];
  List<SRO> _sros = [];
  
  String? _selectedDistrictId;
  String? _selectedSROId;
  
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await _locationService.getDistricts();
      setState(() {
        _districts = districts;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations: $e')),
        );
      }
    }
  }

  void _onDistrictChanged(String? districtId) {
    setState(() {
      _selectedDistrictId = districtId;
      _selectedSROId = null; // Reset SRO
      if (districtId != null) {
        _sros = _locationService.getSROsForDistrict(districtId);
      } else {
        _sros = [];
      }
    });
  }

  void _performSearch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final ecService = Provider.of<ECService>(context, listen: false);

    try {
      final result = await ecService.startSearch(
        district: _selectedDistrictId!,
        sro: _selectedSROId!,
        docNumber: _docNumberController.text,
        year: _yearController.text,
      );
      
      final sessionId = result['sessionId'];

      if (!mounted) return;

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
            child: _isLoadingLocations
                ? const Center(child: CircularProgressIndicator())
                : Form(
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

                        // District Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDistrictId,
                          decoration: const InputDecoration(labelText: 'District'),
                          items: _districts.map((district) {
                            return DropdownMenuItem(
                              value: district.id,
                              child: Text(district.name),
                            );
                          }).toList(),
                          onChanged: _onDistrictChanged,
                          validator: (v) => v == null ? 'Please select a district' : null,
                        ),
                        const SizedBox(height: 16),

                        // SRO Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSROId,
                          decoration: const InputDecoration(labelText: 'SRO'),
                          items: _sros.map((sro) {
                            return DropdownMenuItem(
                              value: sro.id,
                              child: Text(sro.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedSROId = value),
                          validator: (v) => v == null ? 'Please select an SRO' : null,
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
