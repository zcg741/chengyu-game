// TimerViewModel.ets - 计时器ViewModel（使用setInterval兼容API 12+）
import { GAME_CONFIG } from '../utils/Constants';

export type TimerCallback = (remaining: number) => void;
export type TimerFinishCallback = () => void;

export class TimerViewModel {
  private timerId: number = -1;
  private remaining: number = GAME_CONFIG.TIMER_MODE_DURATION;
  private isRunning: boolean = false;
  private onTickCallback?: TimerCallback;
  private onFinishCallback?: TimerFinishCallback;
  
  /**
   * 设置计时器回调
   * @param onTick 每秒回调
   * @param onFinish 结束回调
   */
  setCallbacks(onTick?: TimerCallback, onFinish?: TimerFinishCallback): void {
    this.onTickCallback = onTick;
    this.onFinishCallback = onFinish;
  }
  
  /**
   * 开始计时
   * @param duration 时长（秒），默认60秒
   */
  start(duration?: number): void {
    this.stop();
    
    this.remaining = duration || GAME_CONFIG.TIMER_MODE_DURATION;
    this.isRunning = true;
    
    // 立即触发一次回调
    if (this.onTickCallback) {
      this.onTickCallback(this.remaining);
    }
    
    // 使用setInterval代替@ohos.base.timer
    this.timerId = setInterval(() => {
      this.remaining--;
        
      if (this.onTickCallback) {
        this.onTickCallback(this.remaining);
      }
        
      if (this.remaining <= 0) {
        this.stop();
        if (this.onFinishCallback) {
          this.onFinishCallback();
        }
      }
    }, 1000);
  }
  
  /**
   * 停止计时
   */
  stop(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
  }
  
  /**
   * 暂停计时
   */
  pause(): void {
    if (this.isRunning && this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
      this.isRunning = false;
    }
  }
  
  /**
   * 恢复计时
   */
  resume(): void {
    if (!this.isRunning && this.remaining > 0) {
      this.isRunning = true;
      
      this.timerId = setInterval(() => {
        this.remaining--;
          
        if (this.onTickCallback) {
          this.onTickCallback(this.remaining);
        }
          
        if (this.remaining <= 0) {
          this.stop();
          if (this.onFinishCallback) {
            this.onFinishCallback();
          }
        }
      }, 1000);
    }
  }
  
  /**
   * 获取剩余时间
   */
  getRemaining(): number {
    return this.remaining;
  }
  
  /**
   * 是否正在运行
   */
  isTimerRunning(): boolean {
    return this.isRunning;
  }
  
  /**
   * 重置计时器
   */
  reset(duration?: number): void {
    this.stop();
    this.remaining = duration || GAME_CONFIG.TIMER_MODE_DURATION;
    
    if (this.onTickCallback) {
      this.onTickCallback(this.remaining);
    }
  }
  
  /**
   * 销毁（清理资源）
   */
  destroy(): void {
    this.stop();
    this.onTickCallback = undefined;
    this.onFinishCallback = undefined;
  }
}
