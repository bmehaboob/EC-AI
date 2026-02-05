import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  List<SROOffice> _sroOffices = [];
  
  // Match website flow
  String? _selectedEncumbranceType; // "DocNo" or "None"
  String? _selectedSROId;
  
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadSROOffices();
  }

  Future<void> _loadSROOffices() async {
    try {
      final sros = await _locationService.getAllSROs();
      setState(() {
        _sroOffices = sros;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load SRO offices: $e')),
        );
      }
    }
  }

  void _handleSubmit() async {
    // If "None" is selected, open the property search page
    if (_selectedEncumbranceType == 'None') {
      final url = Uri.parse('https://registration.ec.ap.gov.in/ecSearch/EncumbranceSearch');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open property search page')),
          );
        }
      }
      return;
    }

    // Otherwise, proceed with Document No flow
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final ecService = Provider.of<ECService>(context, listen: false);

    try {
      final result = await ecService.startSearch(
        district: '', // Not used in actual website
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDocumentFields = _selectedEncumbranceType == 'DocNo';

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
                          'e-Encumbrance Service',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Andhra Pradesh IGRS Portal',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Encumbrance Type (matching website)
                        Text(
                          'Select Encumbrance Type *',
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedEncumbranceType,
                          decoration: const InputDecoration(
                            hintText: 'Select',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'DocNo', child: Text('Document No')),
                            DropdownMenuItem(value: 'None', child: Text('None')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedEncumbranceType = value;
                              // Reset form when switching types
                              if (value == 'None') {
                                _selectedSROId = null;
                                _docNumberController.clear();
                                _yearController.clear();
                              }
                            });
                          },
                          validator: (v) => v == null ? 'Please select encumbrance type' : null,
                        ),
                        const SizedBox(height: 24),

                        // Show these fields only if "Document No" is selected
                        if (showDocumentFields) ...[
                          // Doc Number
                          Text(
                            'Enter the Doc No *',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _docNumberController,
                            decoration: const InputDecoration(hintText: 'Enter the Doc No'),
                            keyboardType: TextInputType.number,
                            validator: (v) => showDocumentFields && v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),

                          // Year
                          Text(
                            'Year of Registration *',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(hintText: 'Year of Registration'),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            validator: (v) => showDocumentFields && v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // SRO Office
                          Text(
                            'Registered at SRO *',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedSROId,
                            decoration: const InputDecoration(
                              hintText: 'Registered at SRO',
                            ),
                            items: _sroOffices.map((sro) {
                              return DropdownMenuItem(
                                value: sro.id,
                                child: Text(
                                  sro.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedSROId = value),
                            validator: (v) => showDocumentFields && v == null ? 'Please select an SRO' : null,
                          ),
                          const SizedBox(height: 24),

                          // Info about CAPTCHA
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'CAPTCHA will be shown in the browser window',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Show message for "None" option
                        if (_selectedEncumbranceType == 'None') ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.open_in_new, color: Colors.orange.shade700, size: 32),
                                const SizedBox(height: 12),
                                Text(
                                  'Property Search',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Clicking Submit will open the property search page where you can search by Survey Number, House Number, or Apartment Name.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit'),
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
