abstract class VoiceService {
  /// Speaks the provided [text].
  Future<void> speak(String text);

  /// Starts listening for speech input.
  Future<void> listen();

  /// Stops current speech output.
  Future<void> stopSpeaking();

  /// Stops listening for speech input.
  Future<void> stopListening();

  /// Stream of recognized speech results.
  Stream<String> get speechResults;

  /// Whether the service is currently speaking.
  bool get isSpeaking;

  /// Whether the service is currently listening.
  bool get isListening;
}
