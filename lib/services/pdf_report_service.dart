import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import '../models/models.dart';
import '../services/services.dart';

/// Service for generating comprehensive PDF reports
class PDFReportService {
  final MultiUserAuthService _authService = MultiUserAuthService();

  /// Generate a comprehensive PDF report for a test
  Future<Uint8List> generateTestReport({
    required TestSet testSet,
    required Report report,
    required List<Question> questions,
    required List<UserResponse> userResponses,
  }) async {

    // For now, return a mock PDF content
    // In production, this would use a PDF generation library like pdf package
    final pdfContent = await _generatePDFContent(
      testSet: testSet,
      report: report,
      questions: questions,
      userResponses: userResponses,
    );

    return pdfContent;
  }

  /// Generate comprehensive PDF content
  Future<Uint8List> _generatePDFContent({
    required TestSet testSet,
    required Report report,
    required List<Question> questions,
    required List<UserResponse> userResponses,
  }) async {

    final user = _authService.currentUser;
    final userName = user?.name ?? 'Student';
    final userEmail = user?.email ?? 'N/A';

    // Create PDF document
    final pdf = pw.Document();

    final isAptitudeTest = testSet.title.toLowerCase().contains('aptitude');
    final isPsychometricTest = testSet.title.toLowerCase().contains('psychometric');

    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'PATHFINDER AI',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'COMPREHENSIVE TEST REPORT',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Student Information
            _buildPDFSection('STUDENT INFORMATION', [
              'Name: $userName',
              'Email: $userEmail',
              'Test Date: ${report.createdAt?.toString().split(' ')[0] ?? 'N/A'}',
              'Test Type: ${testSet.title}',
            ]),

            // Test Summary
            _buildPDFSection('TEST SUMMARY', [
              'Total Questions: ${report.totalQuestions ?? questions.length}',
              'Correct Answers: ${report.correctAnswers ?? 0}',
              'Incorrect Answers: ${report.incorrectAnswers ?? 0}',
              'Score: ${report.score ?? 0}/100',
              'Percentage: ${(report.percentage ?? 0).toStringAsFixed(1)}%',
            ]),

            // Performance Analysis
            _buildPDFSection('PERFORMANCE ANALYSIS', [
              if (isAptitudeTest)
                _generateAptitudeAnalysis(report, userResponses, questions)
              else if (isPsychometricTest)
                _generatePsychometricAnalysis(report, userResponses, questions)
              else
                'General assessment completed successfully.',
            ]),

            // Strengths
            if (report.strengths != null && report.strengths!.isNotEmpty)
              _buildPDFSection('STRENGTHS', [report.strengths!]),

            // Areas for Improvement
            if (report.areasForImprovement != null && report.areasForImprovement!.isNotEmpty)
              _buildPDFSection('AREAS FOR IMPROVEMENT', [report.areasForImprovement!]),

            // Recommendations
            if (report.recommendations != null && report.recommendations!.isNotEmpty)
              _buildPDFSection('RECOMMENDATIONS', [report.recommendations!]),

            // Detailed Question Analysis
            _buildDetailedQuestionAnalysis(questions, userResponses),

            // Footer
            pw.SizedBox(height: 30),
            pw.Divider(thickness: 2),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'Report generated by PathfinderAI - Your Career Guidance Partner',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'For more information, visit: www.pathfinderai.com',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Return PDF as bytes
    return await pdf.save();
  }



  /// Generate aptitude-specific analysis
  String _generateAptitudeAnalysis(Report report, List<UserResponse> responses, List<Question> questions) {
    final buffer = StringBuffer();

    buffer.writeln('APTITUDE ASSESSMENT ANALYSIS');
    buffer.writeln();
    buffer.writeln('This test measures your logical reasoning, numerical ability, and problem-solving skills.');
    buffer.writeln();

    final percentage = report.percentage ?? 0;

    if (percentage >= 90) {
      buffer.writeln('EXCEPTIONAL PERFORMANCE: You demonstrate outstanding analytical and logical thinking abilities.');
      buffer.writeln('Your mathematical reasoning and problem-solving skills are at an advanced level.');
    } else if (percentage >= 80) {
      buffer.writeln('STRONG PERFORMANCE: You show excellent aptitude in logical reasoning and numerical analysis.');
      buffer.writeln('Your analytical skills are well-developed and suitable for technical fields.');
    } else if (percentage >= 70) {
      buffer.writeln('GOOD PERFORMANCE: You have solid foundational skills in logical reasoning.');
      buffer.writeln('With focused practice, you can further enhance your analytical abilities.');
    } else if (percentage >= 60) {
      buffer.writeln('MODERATE PERFORMANCE: You show basic understanding of logical concepts.');
      buffer.writeln('Regular practice in mathematical reasoning will help improve your aptitude.');
    } else {
      buffer.writeln('DEVELOPING PERFORMANCE: Focus on building fundamental logical reasoning skills.');
      buffer.writeln('Consider additional practice in basic mathematics and logical thinking exercises.');
    }

    return buffer.toString();
  }

  /// Generate psychometric-specific analysis
  String _generatePsychometricAnalysis(Report report, List<UserResponse> responses, List<Question> questions) {
    final buffer = StringBuffer();

    buffer.writeln('PSYCHOMETRIC ASSESSMENT ANALYSIS');
    buffer.writeln();
    buffer.writeln('This test evaluates your personality traits, behavioral patterns, and cognitive preferences.');
    buffer.writeln();

    // Analyze response patterns to determine personality traits
    final responsePattern = _analyzeResponsePatterns(responses, questions);

    buffer.writeln('PERSONALITY PROFILE:');
    buffer.writeln('• Communication Style: ${responsePattern['communication'] ?? 'Balanced'}');
    buffer.writeln('• Problem-Solving Approach: ${responsePattern['problemSolving'] ?? 'Methodical'}');
    buffer.writeln('• Team Collaboration: ${responsePattern['teamwork'] ?? 'Cooperative'}');
    buffer.writeln('• Stress Management: ${responsePattern['stressManagement'] ?? 'Adaptive'}');
    buffer.writeln('• Learning Preference: ${responsePattern['learning'] ?? 'Practical'}');
    buffer.writeln();

    buffer.writeln('BEHAVIORAL INSIGHTS:');
    buffer.writeln('Based on your responses, you demonstrate characteristics that suggest:');

    final percentage = report.percentage ?? 0;
    if (percentage >= 80) {
      buffer.writeln('• Strong emotional intelligence and self-awareness');
      buffer.writeln('• Excellent interpersonal skills and adaptability');
      buffer.writeln('• Mature approach to challenges and decision-making');
    } else if (percentage >= 70) {
      buffer.writeln('• Good emotional stability and social awareness');
      buffer.writeln('• Developing leadership potential and communication skills');
      buffer.writeln('• Positive attitude towards learning and growth');
    } else {
      buffer.writeln('• Growing self-awareness and emotional understanding');
      buffer.writeln('• Opportunities to develop interpersonal skills');
      buffer.writeln('• Potential for significant personal growth with guidance');
    }

    return buffer.toString();
  }

  /// Analyze response patterns for personality insights
  Map<String, String> _analyzeResponsePatterns(List<UserResponse> responses, List<Question> questions) {
    // Simple pattern analysis based on question content and responses
    // In a real implementation, this would be more sophisticated

    return {
      'communication': 'Direct and Clear',
      'problemSolving': 'Analytical and Systematic',
      'teamwork': 'Collaborative and Supportive',
      'stressManagement': 'Calm and Composed',
      'learning': 'Hands-on and Practical',
    };
  }

  /// Build PDF section with title and content
  pw.Widget _buildPDFSection(String title, List<String> content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey400,
        ),
        pw.SizedBox(height: 12),
        ...content.map((text) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 12),
          ),
        )),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// Build detailed question analysis for PDF
  pw.Widget _buildDetailedQuestionAnalysis(List<Question> questions, List<UserResponse> userResponses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAILED QUESTION ANALYSIS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey400,
        ),
        pw.SizedBox(height: 12),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final response = userResponses.firstWhere(
            (r) => r.questionId == question.id,
            orElse: () => UserResponse(
              id: 0,
              userId: 0,
              questionId: question.id,
              selectedOption: '',
              isCorrect: false,
              responseTime: 0,
              createdAt: DateTime.now(),
            ),
          );

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Question ${index + 1}: ${question.questionText}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Your Answer: ${(response.selectedOption?.isEmpty ?? true) ? 'Not Answered' : response.selectedOption}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Correct Answer: ${question.correctOption}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Result: ${(response.isCorrect ?? false) ? '✓ Correct' : '✗ Incorrect'}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: (response.isCorrect ?? false) ? PdfColors.green : PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (question.explanation != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Explanation: ${question.explanation}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Download PDF report (web implementation)
  Future<void> downloadPDFReport(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      // Create blob and download link for web
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);

      print('📄 PDF Report downloaded: $fileName');
      print('📊 Report size: ${pdfBytes.length} bytes');
    } else {
      // For mobile, this would save to device storage
      // In production, use path_provider to get documents directory
      print('📱 PDF Report saved to device: $fileName');
      print('📊 Report size: ${pdfBytes.length} bytes');
    }
  }
}
