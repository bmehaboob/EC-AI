import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ec_service.dart';
import '../models/ec_entry.dart';
import '../widgets/boundary_diagram.dart';

class ResultsScreen extends StatefulWidget {
  final String sessionId;

  const ResultsScreen({super.key, required this.sessionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = false;
  List<ECEntry> _entries = [];
  String? _pdfUrl;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    // In a real app with manual captcha, we might need a "Ready to Fetch" trigger 
    // or polling. Assuming for MPV the user clicks a button to confirming captcha done.
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Capturing results... this may take a moment.';
    });

    try {
      final ecService = Provider.of<ECService>(context, listen: false);
      final data = await ecService.fetchResults(widget.sessionId);

      final List<dynamic> entriesJson = data['entries'] ?? [];
      final List<ECEntry> parsedEntries = entriesJson
          .map((json) => ECEntry.fromJson(json))
          .toList();

      setState(() {
        _entries = parsedEntries;
        _pdfUrl = data['pdfUrl'];
        _isLoading = false;
        _statusMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _launchPdf() async {
    if (_pdfUrl != null) {
      final uri = Uri.parse(_pdfUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _entries.isEmpty 
        ? _buildWaitingState()
        : _buildResultsList(),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                _statusMessage ?? 'Processing...',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16),
              ),
            ] else ...[
              const Icon(Icons.security, size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Action Required',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Please solve the CAPTCHA in the opened browser window and submit the form.\nOnce you see the results table in the browser, click "Fetch Results" below.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _fetchResults,
                child: const Text('I have submitted the form -> Fetch Results'),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Text(_statusMessage!, style: const TextStyle(color: Colors.red)),
              ]
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length + 1, // +1 for header/PDF button
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_entries.length} Transaction(s) Found',
                  style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.bold
                  ),
                ),
                if (_pdfUrl != null)
                  TextButton.icon(
                    onPressed: _launchPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download Original EC'),
                  ),
              ],
            ),
          );
        }

        final entry = _entries[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        'Doc #${entry.docNumber}',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.date,
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  entry.nature,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  entry.parties,
                  style: GoogleFonts.outfit(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Divider(height: 32),
                
                // The Diagram
                BoundaryDiagram(boundaries: entry.boundaries),
              ],
            ),
          ),
        );
      },
    );
  }
}
