import 'package:flutter/material.dart';
import '../widgets/text_processor_screen.dart';
import '../models/text_area_model.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextProcessorScreen(
      title: "Text Translate",
      apiGet: "translate/getTranslate",
      apiType: "translate-text",
      apiSave: "translate/",
      type: ProcessorType.translate,
      buttonLabel: "Dịch",
      targetLanguage: true,
    );
  }
}