class Appointment {
  final String id;
  final String clientId; // uid del cliente
  final String clientName;
  final String barberId;
  final DateTime date;
  final String hour;
  final String status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.barberId,
    required this.date,
    required this.hour,
    required this.status,
    required this.createdAt,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      clientId: map['clientId'],
      clientName: map['clientName'],
      barberId: map['barberId'],
      date: map['date'].toDate(),
      hour: map['hour'],
      status: map['status'],
      createdAt: map['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "clientId": clientId,
      "clientName": clientName,
      "barberId": barberId,
      "date": date,
      "hour": hour,
      "status": status,
      "createdAt": createdAt,
    };
  }
}
