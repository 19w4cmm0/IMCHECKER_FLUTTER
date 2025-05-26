import 'package:flutter/material.dart';
import '../widgets/text_processor_screen.dart';
import '../models/text_area_model.dart';

class SummarizeScreen extends StatelessWidget {
  const SummarizeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextProcessorScreen(
      title: "Text Summarizer",
      apiGet: "summarize/getSummarize",
      apiType: "summarize-text",
      apiSave: "summarize/",
      type: ProcessorType.summarize,
      buttonLabel: "Tóm tắt",
    );
  }
}