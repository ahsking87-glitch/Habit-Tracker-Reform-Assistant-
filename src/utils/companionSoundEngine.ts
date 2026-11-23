/**
 * Web Audio API procedural synthesizer for the Interactive AI Companion.
 * Adheres strictly to the requirement: "The agent must not use speech.
 * Program it to use distinct, expressive tones, beeps, and micro-sounds for notifications."
 */

export type CompanionSoundType =
  | 'salah_10m'
  | 'screen_threshold'
  | 'habit_celebration'
  | 'gentle_nudge'
  | 'peek_a_boo'
  | 'purr_resting'
  | 'interactive_tap';

class CompanionSoundEngine {
  private audioCtx: AudioContext | null = null;
  private isMuted: boolean = false;
  private volume: number = 0.65;

  private initAudio() {
    if (!this.audioCtx && typeof window !== 'undefined') {
      const AudioContextClass = window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
      if (AudioContextClass) {
        this.audioCtx = new AudioContextClass();
      }
    }
    if (this.audioCtx && this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
  }

  public setMuted(muted: boolean) {
    this.isMuted = muted;
  }

  public setVolume(vol: number) {
    this.volume = Math.max(0, Math.min(1, vol));
  }

  public playSound(type: CompanionSoundType) {
    if (this.isMuted) return;
    try {
      this.initAudio();
      if (!this.audioCtx) return;

      const now = this.audioCtx.currentTime;

      switch (type) {
        case 'salah_10m':
          this.playSalahBell(now);
          break;
        case 'screen_threshold':
          this.playAttentionChime(now);
          break;
        case 'habit_celebration':
          this.playCelebrationHarp(now);
          break;
        case 'peek_a_boo':
          this.playPeekGlissando(now);
          break;
        case 'interactive_tap':
          this.playWaterDrop(now);
          break;
        case 'purr_resting':
          this.playRestingHum(now);
          break;
        case 'gentle_nudge':
        default:
          this.playMarimbaTick(now);
          break;
      }
    } catch {
      // AudioContext might be blocked until user gesture, safely swallow
    }
  }

  private playSalahBell(now: number) {
    if (!this.audioCtx) return;
    const freqs = [432, 648, 864, 1296];
    freqs.forEach((freq, idx) => {
      const osc = this.audioCtx!.createOscillator();
      const gain = this.audioCtx!.createGain();

      osc.type = idx === 0 ? 'sine' : 'triangle';
      osc.frequency.setValueAtTime(freq, now);

      const amp = (this.volume * 0.4) / (idx + 1);
      gain.gain.setValueAtTime(0.001, now);
      gain.gain.linearRampToValueAtTime(amp, now + 0.04);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 2.2);

      osc.connect(gain);
      gain.connect(this.audioCtx!.destination);

      osc.start(now);
      osc.stop(now + 2.3);
    });
  }

  private playAttentionChime(now: number) {
    if (!this.audioCtx) return;
    const tones = [
      { freq: 528, delay: 0 },
      { freq: 396, delay: 0.22 },
    ];

    tones.forEach((t) => {
      const osc = this.audioCtx!.createOscillator();
      const gain = this.audioCtx!.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(t.freq, now + t.delay);

      const start = now + t.delay;
      gain.gain.setValueAtTime(0.001, start);
      gain.gain.linearRampToValueAtTime(this.volume * 0.35, start + 0.03);
      gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.85);

      osc.connect(gain);
      gain.connect(this.audioCtx!.destination);

      osc.start(start);
      osc.stop(start + 0.9);
    });
  }

  private playCelebrationHarp(now: number) {
    if (!this.audioCtx) return;
    const notes = [523.25, 587.33, 659.25, 783.99, 1046.5];
    notes.forEach((freq, i) => {
      const start = now + i * 0.07;
      const osc = this.audioCtx!.createOscillator();
      const gain = this.audioCtx!.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, start);

      gain.gain.setValueAtTime(0.001, start);
      gain.gain.linearRampToValueAtTime(this.volume * 0.3, start + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.9);

      osc.connect(gain);
      gain.connect(this.audioCtx!.destination);

      osc.start(start);
      osc.stop(start + 0.95);
    });
  }

  private playPeekGlissando(now: number) {
    if (!this.audioCtx) return;
    const osc = this.audioCtx.createOscillator();
    const gain = this.audioCtx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(320, now);
    osc.frequency.exponentialRampToValueAtTime(880, now + 0.18);

    gain.gain.setValueAtTime(0.001, now);
    gain.gain.linearRampToValueAtTime(this.volume * 0.3, now + 0.04);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.35);

    osc.connect(gain);
    gain.connect(this.audioCtx.destination);

    osc.start(now);
    osc.stop(now + 0.4);
  }

  private playWaterDrop(now: number) {
    if (!this.audioCtx) return;
    const osc = this.audioCtx.createOscillator();
    const gain = this.audioCtx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(600, now);
    osc.frequency.linearRampToValueAtTime(1100, now + 0.06);

    gain.gain.setValueAtTime(0.001, now);
    gain.gain.linearRampToValueAtTime(this.volume * 0.4, now + 0.015);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.28);

    osc.connect(gain);
    gain.connect(this.audioCtx.destination);

    osc.start(now);
    osc.stop(now + 0.3);
  }

  private playRestingHum(now: number) {
    if (!this.audioCtx) return;
    const osc = this.audioCtx.createOscillator();
    const gain = this.audioCtx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(196, now);
    osc.frequency.linearRampToValueAtTime(220, now + 0.6);

    gain.gain.setValueAtTime(0.001, now);
    gain.gain.linearRampToValueAtTime(this.volume * 0.2, now + 0.2);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 1.2);

    osc.connect(gain);
    gain.connect(this.audioCtx.destination);

    osc.start(now);
    osc.stop(now + 1.25);
  }

  private playMarimbaTick(now: number) {
    if (!this.audioCtx) return;
    const osc = this.audioCtx.createOscillator();
    const gain = this.audioCtx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(740, now);

    gain.gain.setValueAtTime(0.001, now);
    gain.gain.linearRampToValueAtTime(this.volume * 0.3, now + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.12);

    osc.connect(gain);
    gain.connect(this.audioCtx.destination);

    osc.start(now);
    osc.stop(now + 0.15);
  }
}

export const companionAudio = new CompanionSoundEngine();

