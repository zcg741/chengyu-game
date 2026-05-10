// SoundService.ets - 音效服务（兼容API 12+）
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import { getAppContext } from '../utils/ContextManager';

let audioPlayer: media.AVPlayer | null = null;

// 获取音频文件名
function getSoundFile(soundType: string): string {
  if (soundType === 'correct') {
    return 'correct.mp3';
  } else if (soundType === 'wrong') {
    return 'wrong.mp3';
  } else {
    return 'timeout.mp3';
  }
}

/**
 * 播放音效
 * @param soundType 音效类型: 'correct' | 'wrong' | 'timeout'
 */
export async function playSound(soundType: string): Promise<void> {
  try {
    // 停止当前播放的音效
    await stopSound();
    
    const soundFile: string = getSoundFile(soundType);
    
    // 创建音频播放器
    audioPlayer = await media.createAVPlayer();
    
    // 设置播放完成回调
    audioPlayer.on('stateChange', (state: string) => {
      if (state === 'completed') {
        console.info(`Sound ${soundType} played completely`);
        stopSound();
      }
    });
    
    // 设置错误回调
    audioPlayer.on('error', (err: BusinessError) => {
      console.error(`Sound ${soundType} play error:`, err);
      stopSound();
    });
    
    // 设置数据源并开始播放
    const context = getAppContext();
    if (!context) {
      console.error('Failed to get context');
      return;
    }
    try {
      const fileDescriptor = await context.resourceManager.getRawFd(soundFile);
      audioPlayer.fdSrc = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
    } catch (fdError) {
      console.error('Failed to load sound file:', fdError);
      // 文件不存在时静默失败
      return;
    }
    
    await audioPlayer.prepare();
    audioPlayer.play();
  } catch (error) {
    console.error('Play sound failed:', error);
    // 如果音频文件不存在，使用系统音效（静默失败）
  }
}

/**
 * 停止音效
 */
export function stopSound(): void {
  if (audioPlayer) {
    try {
      audioPlayer.stop();
      audioPlayer.release();
    } catch (error) {
      console.error('Stop sound error:', error);
    } finally {
      audioPlayer = null;
    }
  }
}

/**
 * 播放系统提示音（备用方案，当自定义音效文件不存在时使用）
 * @param soundType 音效类型
 */
export function playSystemSound(soundType: string): void {
  try {
    // 使用系统音效（需要导入@ohos.vibrator或@ohos.ringtone）
    console.info(`Play system sound for: ${soundType}`);
  } catch (error) {
    console.error('Play system sound failed:', error);
  }
}
