/**
 * 应用入口
 *
 * 应用级生命周期管理。
 */

import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { PreferencesManager } from './utils/PreferencesManager';
import { ThemeService } from './services/ThemeService';

export default class MainAbility extends UIAbility {
  onCreate(want: Want, param: AbilityConstant.LaunchParam): void {
    console.log('[App] Markdown Editor started');

    // 初始化偏好设置
    PreferencesManager.getInstance().init(this.context);

    // 初始化主题
    ThemeService.getInstance().init();
  }

  onDestroy(): void {
    console.log('[App] Markdown Editor destroyed');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 加载主页面（Index.ets）
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('[App] Failed to load content:', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy(): void {
    // 窗口销毁
  }

  onForeground(): void {
    // 应用切入前台
  }

  onBackground(): void {
    // 应用切入后台
    // 可在此触发自动保存
  }
}
