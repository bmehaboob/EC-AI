import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/boundary_data.dart';

class BoundaryDiagram extends StatelessWidget {
  final BoundaryData boundaries;

  const BoundaryDiagram({super.key, required this.boundaries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Boundary Diagram',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Diagram Layout
          // North
          _buildDirectionText('NORTH', boundaries.north),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // West
              RotatedBox(
                quarterTurns: 3,
                child: _buildDirectionText('WEST', boundaries.west, isHorizontal: false),
              ),
              
              // Center Property Box
              Expanded(
                child: Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home, color: Color(0xFF6C63FF), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'SCHEDULE\nPROPERTY',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C63FF),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // East
              RotatedBox(
                quarterTurns: 1,
                child: _buildDirectionText('EAST', boundaries.east, isHorizontal: false),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // South
          _buildDirectionText('SOUTH', boundaries.south),
        ],
      ),
    );
  }

  Widget _buildDirectionText(String label, String text, {bool isHorizontal = true}) {
    return Column(
      children: [
        if (isHorizontal) ...[
          Text(label, 
            style: GoogleFonts.outfit(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey
            )
          ),
          const SizedBox(height: 4),
        ],
        Container(
          padding: const EdgeInsets.all(8),
          constraints: BoxConstraints(maxWidth: isHorizontal ? 200 : 160),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isHorizontal) ...[
          const SizedBox(height: 4),
          Text(label, 
            style: GoogleFonts.outfit(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey
            )
          ),
        ],
      ],
    );
  }
}
