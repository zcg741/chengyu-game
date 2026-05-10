// ShareService.ets - 分享服务（占位实现，API 12+ 分享模块需另行集成）
/**
 * 分享游戏成绩
 * @param score 得分
 * @param correctCount 答对题数
 */
export function shareScore(score: number, correctCount: number): void {
  try {
    const shareText: string = `我在「妙语成语」中获得了 ${score} 分，答对了 ${correctCount} 题！快来挑战吧！`;
    console.info('Share content: ' + shareText);
    // API 12+ 分享功能需另行集成，当前仅打印日志
  } catch (error) {
    console.error('Share service error:', error);
  }
}

/**
 * 分享文本内容
 * @param text 分享的文本
 */
export function shareText(text: string): void {
  try {
    console.info('Share text: ' + text);
    // API 12+ 分享功能需另行集成，当前仅打印日志
  } catch (error) {
    console.error('Share text error:', error);
  }
}
