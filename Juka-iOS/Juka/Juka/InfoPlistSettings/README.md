# Info.plist 設置說明

為了讓應用正常運行，需要在 Xcode 項目設置中添加以下關鍵配置:

## 位置權限設置

在 Xcode 中打開項目設置，找到 "Info" 部分，添加以下鍵值:

1. **NSLocationWhenInUseUsageDescription**
   - 值: "需要您的位置以在地圖上顯示您的位置和附近的活動"
   - 解釋: 請求用戶允許在應用使用期間訪問位置

2. **NSLocationAlwaysAndWhenInUseUsageDescription**
   - 值: "需要您的位置以在地圖上顯示您的位置，並在背景中提供附近活動的通知"
   - 解釋: 請求在應用使用期間和背景模式下訪問位置

3. **NSLocationAlwaysUsageDescription**
   - 值: "需要您的位置以在地圖上顯示您的位置，並在背景中提供附近活動的通知"
   - 解釋: 請求在所有情況下訪問位置

## 背景模式設置

在項目設置的 "Signing & Capabilities" 部分:

1. 點擊 "+ Capability" 添加新功能
2. 選擇 "Background Modes"
3. 勾選 "Location updates" 選項，允許應用在背景中獲取位置更新

## 解決編譯錯誤

如果遇到 "Multiple commands produce..." 錯誤，可能是由於 Info.plist 文件沖突導致。解決方法:

1. 刪除手動創建的 Info.plist 文件
2. 讓 Xcode 自動生成 Info.plist
3. 在 Xcode 的圖形界面中添加上述所需的配置

## 相關代碼

參見 `MapView.swift` 中的 `LocationManager` 類，它處理位置權限和更新的邏輯。 