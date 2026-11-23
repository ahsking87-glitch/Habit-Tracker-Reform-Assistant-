import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import '../models/mizan_models.dart';

/// Procedural non-verbal audio synthesizer producing 16-bit PCM WAV buffers.
/// Strictly adheres to speech-free acoustic design (432Hz bells, chimes, harps, drops).
class CompanionAudioService {
  CompanionAudioService._();
  static final CompanionAudioService instance = CompanionAudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;
  double _volume = 0.7;

  static const int _sampleRate = 22050;

  void setMuted(bool muted) => _muted = muted;

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  Future<void> playSound(SoundEffectType type) async {
    if (_muted || _volume <= 0.01) return;
    try {
      final wavBytes = _synthesizeWav(type, _volume);
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (_) {
      // Safe fallback on simulators without audio hardware
    }
  }

  Uint8List _synthesizeWav(SoundEffectType type, double vol) {
    late List<double> samples;
    switch (type) {
      case SoundEffectType.salahBell:
        samples = _genSalahBell(vol);
        break;
      case SoundEffectType.attentionChime:
        samples = _genAttentionChime(vol);
        break;
      case SoundEffectType.celebrationHarp:
        samples = _genCelebrationHarp(vol);
        break;
      case SoundEffectType.peekGlissando:
        samples = _genPeekGlissando(vol);
        break;
      case SoundEffectType.waterDrop:
        samples = _genWaterDrop(vol);
        break;
      case SoundEffectType.restingHum:
        samples = _genRestingHum(vol);
        break;
      case SoundEffectType.marimbaTick:
        samples = _genMarimbaTick(vol);
        break;
    }
    return _encodeWav16Mono(samples);
  }

  List<double> _genSalahBell(double vol) {
    const duration = 2.0;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    const freqs = [432.0, 648.0, 864.0, 1296.0];
    for (int i = 0; i < len; i++) {
      final t = i / _sampleRate;
      final env = (t < 0.04 ? t / 0.04 : math.exp(-3.2 * (t - 0.04)));
      double sample = 0;
      for (int f = 0; f < freqs.length; f++) {
        sample += math.sin(2 * math.pi * freqs[f] * t) * (0.35 / (f + 1));
      }
      out[i] = sample * env * vol;
    }
    return out;
  }

  List<double> _genAttentionChime(double vol) {
    const duration = 0.9;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      final t = i / _sampleRate;
      double val = 0;
      if (t < 0.65) {
        final env1 = t < 0.03 ? t / 0.03 : math.exp(-5.0 * (t - 0.03));
        val += math.sin(2 * math.pi * 528.0 * t) * env1 * 0.35;
      }
      if (t >= 0.22) {
        final dt = t - 0.22;
        final env2 = dt < 0.03 ? dt / 0.03 : math.exp(-5.0 * (dt - 0.03));
        val += math.sin(2 * math.pi * 396.0 * dt) * env2 * 0.35;
      }
      out[i] = val * vol;
    }
    return out;
  }

  List<double> _genCelebrationHarp(double vol) {
    const notes = [523.25, 587.33, 659.25, 783.99, 1046.5];
    const duration = 1.05;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    for (int n = 0; n < notes.length; n++) {
      final startSample = (n * 0.07 * _sampleRate).toInt();
      for (int i = startSample; i < len; i++) {
        final t = (i - startSample) / _sampleRate;
        final env = t < 0.02 ? t / 0.02 : math.exp(-4.5 * (t - 0.02));
        out[i] += math.sin(2 * math.pi * notes[n] * t) * env * 0.28 * vol;
      }
    }
    return out;
  }

  List<double> _genPeekGlissando(double vol) {
    const duration = 0.36;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    double phase = 0;
    for (int i = 0; i < len; i++) {
      final t = i / _sampleRate;
      final freq = 320.0 * math.pow(880.0 / 320.0, (t / 0.18).clamp(0.0, 1.0));
      phase += 2 * math.pi * freq / _sampleRate;
      final env = t < 0.04 ? t / 0.04 : math.exp(-8.5 * (t - 0.04));
      out[i] = math.sin(phase) * env * 0.32 * vol;
    }
    return out;
  }

  List<double> _genWaterDrop(double vol) {
    const duration = 0.28;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    double phase = 0;
    for (int i = 0; i < len; i++) {
      final t = i / _sampleRate;
      final freq = 600.0 + (500.0 * (t / 0.06).clamp(0.0, 1.0));
      phase += 2 * math.pi * freq / _sampleRate;
      final env = t < 0.015 ? t / 0.015 : math.exp(-11.0 * (t - 0.015));
      out[i] = math.sin(phase) * env * 0.42 * vol;
    }
    return out;
  }

  List<double> _genRestingHum(double vol) {
    const duration = 1.1;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    double phase = 0;
    for (int i = 0; i < len; i++) {
      final t = i / _sampleRate;
      final freq = 196.0 + (24.0 * (t / 0.6).clamp(0.0, 1.0));
      phase += 2 * math.pi * freq / _sampleRate;
      final env = t < 0.2 ? t / 0.2 : math.exp(-3.0 * (t - 0.2));
      out[i] = math.sin(phase) * env * 0.24 * vol;
    }
    return out;
  }

  List<double> _genMarimbaTick(double vol) {
    const duration = 0.14;
    final len = (_sampleRate * duration).toInt();
    final out = List<double>.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      final t = i / _sampleRate;
      final env = t < 0.01 ? t / 0.01 : math.exp(-24.0 * (t - 0.01));
      out[i] = math.sin(2 * math.pi * 740.0 * t) * env * 0.35 * vol;
    }
    return out;
  }

  Uint8List _encodeWav16Mono(List<double> samples) {
    final byteCount = samples.length * 2;
    final buffer = ByteData(44 + byteCount);

    void writeAscii(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        buffer.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    buffer.setUint32(4, 36 + byteCount, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little); // PCM
    buffer.setUint16(20, 1, Endian.little); // Linear PCM
    buffer.setUint16(22, 1, Endian.little); // Mono
    buffer.setUint32(24, _sampleRate, Endian.little);
    buffer.setUint32(28, _sampleRate * 2, Endian.little);
    buffer.setUint16(32, 2, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    buffer.setUint32(40, byteCount, Endian.little);

    for (int i = 0; i < samples.length; i++) {
      final clamped = samples[i].clamp(-0.98, 0.98);
      buffer.setInt16(44 + i * 2, (clamped * 32767).round(), Endian.little);
    }

    return buffer.buffer.asUint8List();
  }
}
