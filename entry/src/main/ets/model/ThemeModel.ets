// ThemeModel.ets - 主题数据模型
export interface Theme {
  id: string;
  name: string;
  // 品牌主色
  brand: string;
  // 页面背景色
  bgPage: string;
  // 卡片背景色
  bgCard: string;
  // 边框色
  border: string;
  // 主文本色
  textPrimary: string;
  // 次文本色
  textSecondary: string;
  // 浅底背景（高亮卡片）
  bgLight: string;
}

export const THEMES: Record<string, Theme> = {
  classic: {
    id: 'classic',
    name: '经典橙',
    brand: '#FF6B35',
    bgPage: '#FAFAF7',
    bgCard: '#FFFFFF',
    border: '#E8E6E1',
    textPrimary: '#2C2C2C',
    textSecondary: '#888888',
    bgLight: '#FFF5F0'
  },
  green: {
    id: 'green',
    name: '清新绿',
    brand: '#4CAF50',
    bgPage: '#F7FAF7',
    bgCard: '#FFFFFF',
    border: '#E1E8E1',
    textPrimary: '#2C2C2C',
    textSecondary: '#888888',
    bgLight: '#F0FAF0'
  },
  blue: {
    id: 'blue',
    name: '深海蓝',
    brand: '#2196F3',
    bgPage: '#F7F9FA',
    bgCard: '#FFFFFF',
    border: '#E1E6E8',
    textPrimary: '#2C2C2C',
    textSecondary: '#888888',
    bgLight: '#F0F5FA'
  },
  dark: {
    id: 'dark',
    name: '暗夜黑',
    brand: '#BB86FC',
    bgPage: '#121212',
    bgCard: '#1E1E1E',
    border: '#333333',
    textPrimary: '#E0E0E0',
    textSecondary: '#888888',
    bgLight: '#2A2A2A'
  }
};
