import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_logo.dart';
import '../services/logo_service.dart';

class LogoState {
  final List<BusinessLogo> logos;
  final bool loading;
  final String? error;

  LogoState({
    required this.logos,
    required this.loading,
    this.error,
  });

  LogoState copyWith({
    List<BusinessLogo>? logos,
    bool? loading,
    String? error,
  }) {
    return LogoState(
      logos: logos ?? this.logos,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class LogoNotifier extends StateNotifier<LogoState> {
  final LogoService service;
  final String userId;
  final String promotionId;

  LogoNotifier(this.service, this.userId, this.promotionId)
      : super(LogoState(logos: [], loading: false));

  Future<void> loadLogos() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final logos = await service.getLogos(userId, promotionId);
      state = state.copyWith(logos: logos, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> uploadLogo(File imageFile) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await service.uploadLogo(userId, promotionId, imageFile);
      await loadLogos();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateLogo(String logoId, File newImage) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await service.updateLogo(userId, promotionId, logoId, newImage);
      await loadLogos();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteLogo(String logoId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await service.deleteLogo(userId, promotionId, logoId);
      await loadLogos();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }
}

final logoProvider = StateNotifierProvider.family<LogoNotifier, LogoState, Map<String, String>>((ref, args) {
  final service = LogoService();
  final userId = args['userId']!;
  final promotionId = args['promotionId']!;
  return LogoNotifier(service, userId, promotionId);
});

