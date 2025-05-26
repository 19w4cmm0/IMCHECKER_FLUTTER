import 'package:flutter/material.dart';
import '../widgets/text_processor_screen.dart';
import '../models/text_area_model.dart';

class GrammarCheckerScreen extends StatelessWidget {
  const GrammarCheckerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextProcessorScreen(
      title: "Grammar Checker",
      apiGet: "grammar/getGrammar",
      apiType: "check-grammar",
      apiSave: "grammar/",
      type: ProcessorType.grammar,
      buttonLabel: "Thực hiện",
    );
  }
}