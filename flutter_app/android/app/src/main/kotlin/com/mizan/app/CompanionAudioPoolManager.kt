package com.mizan.app

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import kotlin.math.exp
import kotlin.math.sin

/**
 * CompanionAudioPoolManager
 * Zero-latency procedural non-verbal PCM tone generator for the bounded Nūr companion.
 * Zero speech synthesis.
 */
class CompanionAudioPoolManager private constructor(context: Context) {

    private var volume = 0.7f

    fun playSalah10mBell() = playSineSweep(432.0, 648.0, 900)
    fun playScreenLimitChime() = playSineSweep(528.0, 396.0, 450)
    fun playHarpCelebration() = playSineSweep(523.25, 1046.5, 420)
    fun playWaterDropTap() = playSineSweep(600.0, 1100.0, 220)
    fun playPeekGlissando() = playSineSweep(320.0, 880.0, 280)
    fun playRestingPurr() = playSineSweep(196.0, 220.0, 600)
    fun playMarimbaTick() = playSineSweep(740.0, 740.0, 110)

    fun setVolume(vol: Float) {
        volume = vol.coerceIn(0.0f, 1.0f)
    }

    private fun playSineSweep(startFreq: Double, endFreq: Double, durationMs: Int) {
        Thread {
            try {
                val sampleRate = 22050
                val count = (sampleRate * durationMs) / 1000
                val samples = ShortArray(count)
                var phase = 0.0
                for (i in 0 until count) {
                    val progress = i.toDouble() / count
                    val freq = startFreq + (endFreq - startFreq) * progress
                    phase += 2.0 * Math.PI * freq / sampleRate
                    val env = exp(-4.0 * progress) * volume
                    samples[i] = (sin(phase) * env * Short.MAX_VALUE * 0.5).toInt().toShort()
                }
                val track = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(samples.size * 2)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()
                track.write(samples, 0, samples.size)
                track.play()
                Thread.sleep(durationMs.toLong() + 50L)
                track.release()
            } catch (_: Throwable) {}
        }.start()
    }

    companion object {
        @Volatile
        private var instance: CompanionAudioPoolManager? = null

        fun getInstance(context: Context): CompanionAudioPoolManager {
            return instance ?: synchronized(this) {
                instance ?: CompanionAudioPoolManager(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }
}
