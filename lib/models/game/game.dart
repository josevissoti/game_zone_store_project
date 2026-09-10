class GameModel {
  const GameModel({
    required this.id,
    required this.nome,
    required this.preco,
    required this.dataPublicacao,
    required this.empresa,
    required this.genero,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  final String id;
  final String nome;
  final double preco;
  final DateTime dataPublicacao;
  final String empresa;
  final String genero;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  factory GameModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GameModel(
      id: documentId,
      nome: (data['nome'] as String?) ?? '',
      preco: (data['preco'] as num?)?.toDouble() ?? 0.0,
      dataPublicacao: _dateTimeFromValue(data['dataPublicacao']),
      empresa: (data['empresa'] as String?) ?? '',
      genero: (data['genero'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: _dateTimeFromValue(data['createdAt']),
      updatedAt: _dateTimeFromValue(data['updatedAt']),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome.trim(),
      'preco': preco,
      'dataPublicacao': dataPublicacao.millisecondsSinceEpoch,
      'empresa': empresa.trim(),
      'genero': genero.trim(),
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
    };
  }

  GameModel copyWith({
    String? id,
    String? nome,
    double? preco,
    DateTime? dataPublicacao,
    String? empresa,
    String? genero,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return GameModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      dataPublicacao: dataPublicacao ?? this.dataPublicacao,
      empresa: empresa ?? this.empresa,
      genero: genero ?? this.genero,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  static DateTime _dateTimeFromValue(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  bool get isOwner => createdBy == id;

  String get formattedPrice {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get formattedDate {
    final day = dataPublicacao.day.toString().padLeft(2, '0');
    final month = dataPublicacao.month.toString().padLeft(2, '0');
    final year = dataPublicacao.year;
    return '$day/$month/$year';
  }
}