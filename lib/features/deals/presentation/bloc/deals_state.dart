import '../../domain/entities/deal_entity.dart';

abstract class DealsState {}

class DealsInitial extends DealsState {}

class DealsLoading extends DealsState {}

class DealsLoaded extends DealsState {
  final List<Deal> deals;
  final List<Deal> filteredDeals;
  
  DealsLoaded({
    required this.deals,
    required this.filteredDeals,
  });
}

class DealsError extends DealsState {
  final String message;
  
  DealsError({required this.message});
}

class DealCreated extends DealsState {
  final Deal deal;
  final String message;
  
  DealCreated({
    required this.deal,
    required this.message,
  });
}

class DealUpdated extends DealsState {
  final Deal deal;
  final String message;
  
  DealUpdated({
    required this.deal,
    required this.message,
  });
}

class DealDeleted extends DealsState {
  final int dealId;
  final String message;
  
  DealDeleted({
    required this.dealId,
    required this.message,
  });
}

class DealCompleted extends DealsState {
  final Deal deal;
  final String message;
  
  DealCompleted({
    required this.deal,
    required this.message,
  });
}

class DealCancelled extends DealsState {
  final Deal deal;
  final String message;
  
  DealCancelled({
    required this.deal,
    required this.message,
  });
}

class DealDetailsLoaded extends DealsState {
  final Deal deal;
  
  DealDetailsLoaded({required this.deal});
}

class DealsFiltered extends DealsState {
  final List<Deal> filteredDeals;
  
  DealsFiltered({required this.filteredDeals});
}

class DealFilterOptionsLoading extends DealsState {}

class DealFilterOptionsLoaded extends DealsState {
  final List<Map<String, String>> statuses;
  final List<Map<String, String>> types;
  
  DealFilterOptionsLoaded({
    required this.statuses,
    required this.types,
  });
}

class DealFilterOptionsError extends DealsState {
  final String message;
  
  DealFilterOptionsError({required this.message});
}