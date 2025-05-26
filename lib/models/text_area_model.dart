enum ProcessorType { grammar, translate, summarize }

class TextAreaModel {
  final String id;
  String text;
  String? result;
  String status;

  TextAreaModel({
    required this.id,
    required this.text,
    this.result,
    this.status = 'normal',
  });
}