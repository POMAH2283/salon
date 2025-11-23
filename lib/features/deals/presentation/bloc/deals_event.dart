abstract class DealsEvent {}

class LoadDealsEvent extends DealsEvent {}

class CreateDealEvent extends DealsEvent {
  final int carId;
  final String clientName;
  final int managerId;
  final String type; // 'sale' или 'reservation'
  
  CreateDealEvent({
    required this.carId,
    required this.clientName,
    required this.managerId,
    required this.type,
  });
}

class UpdateDealStatusEvent extends DealsEvent {
  final int dealId;
  final String status;
  
  UpdateDealStatusEvent({
    required this.dealId,
    required this.status,
  });
}

class UpdateDealEvent extends DealsEvent {
  final int dealId;
  final int carId;
  final String clientName;
  final int managerId;
  final String type;
  final String status;
  
  UpdateDealEvent({
    required this.dealId,
    required this.carId,
    required this.clientName,
    required this.managerId,
    required this.type,
    required this.status,
  });
}

class DeleteDealEvent extends DealsEvent {
  final int dealId;
  
  DeleteDealEvent({required this.dealId});
}

class CompleteDealEvent extends DealsEvent {
  final int dealId;
  
  CompleteDealEvent({required this.dealId});
}

class CancelDealEvent extends DealsEvent {
  final int dealId;
  
  CancelDealEvent({required this.dealId});
}

class LoadDealDetailsEvent extends DealsEvent {
  final int dealId;
  
  LoadDealDetailsEvent({required this.dealId});
}

class FilterDealsEvent extends DealsEvent {
  final String? status;
  final String? type;
  final String? managerId;
  final String? clientName;
  
  FilterDealsEvent({
    this.status,
    this.type,
    this.managerId,
    this.clientName,
  });
}

class LoadDealFilterOptionsEvent extends DealsEvent {}