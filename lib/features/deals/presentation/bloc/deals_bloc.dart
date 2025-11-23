import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/deal_entity.dart';
import '../../domain/repositories/deals_repository.dart';
import 'deals_event.dart';
import 'deals_state.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState> {
  final DealsRepository _dealsRepository;
  
  DealsBloc(this._dealsRepository) : super(DealsInitial()) {
    on<LoadDealsEvent>(_onLoadDeals);
    on<CreateDealEvent>(_onCreateDeal);
    on<UpdateDealStatusEvent>(_onUpdateDealStatus);
    on<UpdateDealEvent>(_onUpdateDeal);
    on<DeleteDealEvent>(_onDeleteDeal);
    on<CompleteDealEvent>(_onCompleteDeal);
    on<CancelDealEvent>(_onCancelDeal);
    on<LoadDealDetailsEvent>(_onLoadDealDetails);
    on<FilterDealsEvent>(_onFilterDeals);
    on<LoadDealFilterOptionsEvent>(_onLoadDealFilterOptions);
  }

  Future<void> _onLoadDeals(LoadDealsEvent event, Emitter<DealsState> emit) async {
    try {
      emit(DealsLoading());
      final deals = await _dealsRepository.getDeals();
      emit(DealsLoaded(
        deals: deals,
        filteredDeals: deals,
      ));
    } catch (e) {
      emit(DealsError(message: e.toString()));
    }
  }

  Future<void> _onCreateDeal(CreateDealEvent event, Emitter<DealsState> emit) async {
    try {
      final deal = await _dealsRepository.createDeal(
        carId: event.carId,
        clientName: event.clientName,
        managerId: event.managerId,
        type: event.type,
      );
      emit(DealCreated(
        deal: deal,
        message: 'Сделка успешно создана',
      ));
    } catch (e) {
      emit(DealsError(message: 'Ошибка создания сделки: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDealStatus(UpdateDealStatusEvent event, Emitter<DealsState> emit) async {
    try {
      final deal = await _dealsRepository.updateDealStatus(
        dealId: event.dealId,
        status: event.status,
      );
      emit(DealUpdated(
        deal: deal,
        message: 'Статус сделки обновлен',
      ));
    } catch (e) {
      emit(DealsError(message: 'Ошибка обновления статуса: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDeal(UpdateDealEvent event, Emitter<DealsState> emit) async {
    try {
      final deal = await _dealsRepository.updateDeal(
        dealId: event.dealId,
        carId: event.carId,
        clientName: event.clientName,
        managerId: event.managerId,
        type: event.type,
        status: event.status,
      );
      emit(DealUpdated(
        deal: deal,
        message: 'Сделка успешно обновлена',
      ));
    } catch (e) {
      emit(DealsError(message: 'Ошибка обновления сделки: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteDeal(DeleteDealEvent event, Emitter<DealsState> emit) async {
    try {
      await _dealsRepository.deleteDeal(event.dealId);
      emit(DealDeleted(
        dealId: event.dealId,
        message: 'Сделка успешно удалена',
      ));
    } catch (e) {
      emit(DealsError(message: 'Ошибка удаления сделки: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteDeal(CompleteDealEvent event, Emitter<DealsState> emit) async {
    try {
      final deal = await _dealsRepository.completeDeal(event.dealId);
      emit(DealCompleted(
        deal: deal,
        message: 'Сделка успешно завершена',
      ));
    } catch (e) {
      emit(DealsError(message: 'Ошибка завершения сделки: ${e.toString()}'));
    }
  }

  Future<void> _onCancelDeal(CancelDealEvent event, Emitter<DealsState> emit) async {
    try {
      final deal = await _dealsRepository.cancelDeal(event.dealId);
      emit(DealCancelled(
        deal: deal,
        message: 'Сделка отменена',
      ));
    } catch (e) {
      emit(DealsError(message: 'Ошибка отмены сделки: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDealDetails(LoadDealDetailsEvent event, Emitter<DealsState> emit) async {
    try {
      emit(DealsLoading());
      final deal = await _dealsRepository.getDealById(event.dealId);
      emit(DealDetailsLoaded(deal: deal));
    } catch (e) {
      emit(DealsError(message: 'Ошибка загрузки деталей сделки: ${e.toString()}'));
    }
  }

  Future<void> _onFilterDeals(FilterDealsEvent event, Emitter<DealsState> emit) async {
    try {
      final currentState = state;
      if (currentState is DealsLoaded) {
        List<Deal> filteredDeals = currentState.deals;
        
        if (event.status != null) {
          filteredDeals = filteredDeals.where((deal) => deal.status == event.status).toList();
        }
        
        if (event.type != null) {
          filteredDeals = filteredDeals.where((deal) => deal.type == event.type).toList();
        }
        
        if (event.managerId != null) {
          filteredDeals = filteredDeals.where((deal) => deal.managerName?.toLowerCase().contains(event.managerId!.toLowerCase()) ?? false).toList();
        }
        
        if (event.clientName != null) {
          filteredDeals = filteredDeals.where((deal) => deal.clientName?.toLowerCase().contains(event.clientName!.toLowerCase()) ?? false).toList();
        }
        
        emit(DealsLoaded(
          deals: currentState.deals,
          filteredDeals: filteredDeals,
        ));
      }
    } catch (e) {
      emit(DealsError(message: 'Ошибка фильтрации: ${e.toString()}'));
    }
  }
  Future<void> _onLoadDealFilterOptions(LoadDealFilterOptionsEvent event, Emitter<DealsState> emit) async {
    emit(DealFilterOptionsLoading());
    try {
      final statuses = await _dealsRepository.getDealStatuses();
      final types = await _dealsRepository.getDealTypes();
      
      emit(DealFilterOptionsLoaded(
        statuses: statuses,
        types: types,
      ));
    } catch (e) {
      emit(DealFilterOptionsError(message: 'Ошибка загрузки опций фильтра: $e'));
    }
  }
}