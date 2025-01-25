// lib/models/course_model.dart

class Course {
  final String codeEM;
  final String titre;
  final int creditsEM;
  final int cm;
  final int td;
  final int tp;
  final int? mp;
  final int? vhtEM;
  final String profCM;
  final String profTD;
  final String profTP;
  final String? profMP;
  final String salleCM;
  final String salleTP;

  Course({
    required this.codeEM,
    required this.titre,
    required this.creditsEM,
    required this.cm,
    required this.td,
    required this.tp,
    this.mp,
    this.vhtEM,
    required this.profCM,
    required this.profTD,
    required this.profTP,
    this.profMP,
    required this.salleCM,
    required this.salleTP,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      codeEM: json['code_em'],
      titre: json['titre'],
      creditsEM: json['credits_em'],
      cm: json['cm'],
      td: json['td'],
      tp: json['tp'],
      mp: json['mp'],
      vhtEM: json['vht_em'],
      profCM: json['prof_cm'],
      profTD: json['prof_td'],
      profTP: json['prof_tp'],
      profMP: json['prof_mp'],
      salleCM: json['salle_cm'],
      salleTP: json['salle_tp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code_em': codeEM,
      'titre': titre,
      'credits_em': creditsEM,
      'cm': cm,
      'td': td,
      'tp': tp,
      'mp': mp,
      'vht_em': vhtEM,
      'prof_cm': profCM,
      'prof_td': profTD,
      'prof_tp': profTP,
      'prof_mp': profMP,
      'salle_cm': salleCM,
      'salle_tp': salleTP,
    };
  }
}