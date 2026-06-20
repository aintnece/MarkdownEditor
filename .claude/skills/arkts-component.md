# ArkTS Component Template

When asked to create or modify an ArkTS component for HarmonyOS NEXT (API 12 / DevEco Studio 5.0+), always follow this template.

## File Extension

- UI components: `.ets`
- Pure logic/utilities: `.ts`

## Template

```typescript
import { ... } from '@kit.ArkUI'

// Classes used in @State must be file-level (not inside struct)
@Observed
export class SomeModel {
  value: string = ''
  count: number = 0
}

@Component
export struct ComponentName {
  // ── Props ──
  @Prop @Watch('onPropChange') someProp: string = ''
  @Link someLink: SomeModel

  // ── State ──
  @State private uiFlag: boolean = false
  @State private data: SomeModel = new SomeModel()

  // ── Lifecycle ──
  aboutToAppear(): void {
    // Initialize here, NOT in constructor
  }

  aboutToDisappear(): void {
    // Cleanup
  }

  // ── Watchers ──
  onPropChange(): void {
    // React to @Prop changes
  }

  // ── Private Methods ──
  private doSomething(): void {
    // ...
  }

  // ── Build ──
  build() {
    Column() {
      // UI
    }
    .width('100%')
    .height('100%')
  }
}
```

## Critical Rules (ArkTS Strict Mode)

| ❌ Forbidden | ✅ Use |
|---|---|
| `{ ...obj }` spread | Explicit field assignment |
| `obj[key]` index | `obj.field` (compile-time keys only) |
| `Record<string, T>` / `Map` | Class + if-else chains |
| `any` / `unknown` type | Specific type |
| `catch (e: Error)` | `catch (e)` (no type annotation) |
| `this` in arrow callback | `const self = this; self.xxx` |
| class inside struct | Move to file level |
| import mid-file | All imports at top |
| `\n` concatenation | Template literals (backticks) |
| Regex with `\` | `.split().join()` |

## Style

- Comments in Chinese
- `@Link` for child→parent mutation, `@Prop` for one-way
- Use `@Observed` for class used as @State
- SidePanel root MUST be `Row()`, not `Column()`
- `PanGesture.offsetX` is cumulative — use delta pattern
