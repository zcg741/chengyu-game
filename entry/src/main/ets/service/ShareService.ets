// ShareService.ets - 分享服务
import pasteboard from '@ohos.pasteboard';
import systemShare from '@hms.collaboration.systemShare';
import uniformTypeDescriptor from '@ohos.data.uniformTypeDescriptor';
import { getAppContext } from '../utils/ContextManager';

export function buildScoreShareText(score: number, correctCount: number, totalQuestions: number, accuracy: string): string {
  const totalText = totalQuestions > 0 ? ` / ${totalQuestions} 题` : ' 题';
  return `【妙语成语】挑战结束！\n🏆 最终得分：${score} 分\n✅ 答对：${correctCount}${totalText}\n📊 正确率：${accuracy}%\n\n💪 快来和我一起玩「妙语成语」吧！`;
}

export async function copyText(text: string): Promise<boolean> {
  try {
    const systemPasteboard = pasteboard.getSystemPasteboard();
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    await systemPasteboard.setData(pasteData);
    return true;
  } catch (error) {
    console.error('ShareService.copyText error:', error);
    return false;
  }
}

export async function openSystemShare(text: string): Promise<boolean> {
  const context = getAppContext();
  if (!context) {
    return false;
  }

  try {
    const record: systemShare.SharedRecord = {
      utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
      content: text,
      title: '妙语成语',
      description: '分享我的成语挑战成绩'
    };
    const data = new systemShare.SharedData(record);
    const controller = new systemShare.ShareController(data);
    await controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DEFAULT,
      selectionMode: systemShare.SelectionMode.SINGLE
    });
    return true;
  } catch (error) {
    console.error('ShareService.openSystemShare error:', error);
    return false;
  }
}

export async function shareText(text: string): Promise<boolean> {
  const shared = await openSystemShare(text);
  if (shared) {
    return true;
  }
  return copyText(text);
}

export async function shareScore(score: number, correctCount: number, totalQuestions: number = 0, accuracy: string = '0'): Promise<boolean> {
  return shareText(buildScoreShareText(score, correctCount, totalQuestions, accuracy));
}
