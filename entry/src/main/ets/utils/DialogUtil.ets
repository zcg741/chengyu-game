// DialogUtil.ets - 弹窗工具封装（替代已弃用的 AlertDialog.show）
import promptAction from '@ohos.promptAction';

export interface InfoDialogOptions {
  title: string;
  message: string;
  confirmText?: string;
  onConfirm?: () => void;
}

export interface ConfirmDialogOptions {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void;
  onCancel?: () => void;
}

/**
 * 显示信息弹窗
 * @param title 标题
 * @param message 内容
 * @param confirmText 确认按钮文字（默认"知道了"）
 */
export function showInfoDialog(options: InfoDialogOptions): void {
  const confirmText = options.confirmText ? options.confirmText : '知道了';
  const buttons: promptAction.Button[] = [
    {
      text: confirmText,
      color: '#FF6B35'
    }
  ];

  promptAction.showDialog({
    title: options.title,
    message: options.message,
    buttons: buttons
  }).then(() => {
    if (options.onConfirm) {
      options.onConfirm();
    }
  }).catch(() => {});
}

/**
 * 显示确认弹窗
 * @param title 标题
 * @param message 内容
 * @param onConfirm 确认回调
 * @param onCancel 取消回调（可选）
 */
export function showConfirmDialog(options: ConfirmDialogOptions): void {
  const confirmText = options.confirmText ? options.confirmText : '确定';
  const cancelText = options.cancelText ? options.cancelText : '取消';
  const buttons: promptAction.Button[] = [
    {
      text: cancelText,
      color: '#666666'
    },
    {
      text: confirmText,
      color: '#FF6B35'
    }
  ];

  promptAction.showDialog({
    title: options.title,
    message: options.message,
    buttons: buttons
  }).then((result: promptAction.ShowDialogSuccessResponse) => {
    // result.index: 0=第一个按钮（取消），1=第二个按钮（确认）
    if (result.index === 1) {
      options.onConfirm();
    } else if (options.onCancel) {
      options.onCancel();
    }
  }).catch(() => {});
}
