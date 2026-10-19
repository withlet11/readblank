#lang racket

;; ============================================================
;; Constants
;; ============================================================

(define (make-description t) `("description" ,t))
(define (make-variables . lst) `("placeholders" ,@lst))

(define (set-variable name
                      #:type [t #f]
                      #:format [f #f]
                      #:isCustomDateFormat [b #f])
  `(,name ,@(if t `(("type" ,t)) '())
          ,@(if f `(("format" ,f)) '())
          ,@(if b `(("isCustomDateFormat" "true")) '())))


;; ============================================================
;; Data
;; ============================================================
;; Instructions:
;; - The default language is "en". Specify other languages using
;;   codes such as "ja-rJP".
;; - Use "*" to mark strings that should not be translated.
;;   These strings are included only in the default file and are
;;   marked with translatable="false".
;; - Specify the output directories for localized files in
;;   `lang-list`.
;; - Specify the strings in `value-list`.
;; - Specify additional attributes after the string.

(define lang-list '((en "../lib/l10n/app_en.arb")
                    (ja "../lib/l10n/app_ja.arb")
                    (hu "../lib/l10n/app_hu.arb")
                    ;; (fr-rFR "../lib/l10n/app_fr.arb")
                    ;; (zh-rCN "../lib/l10n/app_zh.arb")
                    ))




(define value-list
  `(("buyForLabel"
     ((en "Buy for {price}"
          ,(make-variables
            (set-variable "price" #:type "String")))
      (ja "{price}で購入")
      (hu "Vásárlás: {price}")))
    ("restorePurchasesLabel"
     ((en "Restore Purchases")
      (ja "購入を復元")
      (hu "Vásárlások visszaállítása")))
    ("beginningOfWordsLabel"
     ((en "Beginning")
      (ja "先頭")
      (hu "eleje")))
    ("endOfWordsLabel"
     ((en "End")
      (ja "末尾")
      (hu "vége")))
    ("activityBackupCancelledMessage"
     ((en "Activity backup cancelled.")
      (ja "アクティビティのバックアップをキャンセルしました。")
      (hu "A tevékenység biztonsági mentése megszakítva.")))
    ("activityBackupCompletedMessage"
     ((en "Activity backup completed.")
      (ja "アクティビティのバックアップを完了しました。")
      (hu "A tevékenység biztonsági mentése elkészült.")))
    ("activityBackupLabel"
     ((en "Backup Activity")
      (ja "アクティビティをバックアップ")
      (hu "Tevékenység biztonsági mentése")))
    ("activityBackupNotFound"
     ((en "Backup file not found: {path}")
      (ja "バックアップファイルが見つかりません: {path}")
      (hu "Mentési fájl nem található: {path}")))
    ("activityNavButton"
     ((en "Activity")
      (ja "アクティビティ")
      (hu "Tevékenység")))
    ("activityRestoreErrorMessage"
     ((en "failed to restore activities: {error}"
          ,(make-description "Error message shown when restoring contents fails.")
          ,(make-variables
            (set-variable "error" #:type "String")))
      (ja "アクティビティをリストアできませんでした：{error}")
      (hu "Nem sikerült a tevékenység visszaállítása: {error}")))
    ("activityRestoreLabel"
     ((en "Restore Activity")
      (ja "アクティビティを復元")
      (hu "Tevékenység visszaállítása")))
    ("activityRestoreSuccessMessage"
     ((en "Activity restored successfully: {count, plural, zero {no words} one {1 word} other {{count} words}}"
          ,(make-description "Formated text for word count.")
          ,(make-variables
            (set-variable "count" #:type "int")))
      (ja "アクティビティを復元しました：{count}単語")
      (hu "Tevékenység sikeresen visszaállítva: {count} szó")))
    ("activityRestoreSuccess"
     ((en "Activity restored successfully")
      (ja "アクティビティを復元しました")
      (hu "Tevékenység sikeresen visszaállítva")))
    ("allContentsClearButton"
     ((en "Clear all contents"
          ,(make-description "A label of clear all contents."))
      (ja "すべてのコンテンツの削除")
      (hu "Összes tartalmak törlése")))
    ("allContentsClearConfirmation"
     ((en "Are you sure you want to clear all contents?"
          ,(make-description "Confirmation message shown before clearing all contents."))
      (ja "すべてのコンテンツを削除します。よろしいですか？")
      (hu "Biztosan törli az összes tartalmat?")))
    ("allLanguage"
     ((en "All🌐")
      (ja "すべて🌐")
      (hu "Összes🌐")))
    ("alreadyExistsMessage"
     ((en "Already exists")
      (ja "既に存在します")
      (hu "Már létezik")))
    ("appLegalese"
     ((en "© 2026 WITHLET11. Source code licensed under the MIT License. Brand & Assets Reserved.")
      (ja "© 2026 WITHLET11. ソースコードはMIT Licenseに基づきます。ブランドおよびアセットは留保されています。")
      (hu "© 2026 WITHLET11. A forráskód az MIT License feltételei szerint használható. A márka és az egyéb elemek jogai fenntartva.")))
    ("appName"
     ((en "ReadBlank")
      (ja "ReadBlank")
      (hu "ReadBlank")))
    ("appVersion"
     ((en "1.0.1")
      (ja "1.0.1")
      (hu "1.0.1")))
    ("backupButton"
     ((en "Backup")
      (ja "バックアップ")
      (hu "Mentése")))
    ("backupDescription"
     ((en "Backup & Restore")
      (ja "バックアップの作成と復元")
      (hu "Biztonsági mentés és visszaállítás")))
    ("backupLabel"
     ((en "Backup")
      (ja "バックアップ")
      (hu "Biztonsági mentés")))
    ("clipboardEmptyMessage"
     ((en "The clipboard is empty. Please copy the exported data."
          ,(make-description "Error message shown when the clipboard is empty before importing JSON data."))
      (ja "クリップボードが空です。エクスポートデータのコピーが必要です。")
      (hu "A vágólap üres. Kérjük, másolja ki az exportált adatokat.")))
    ("commonCancel"
     ((en "Cancel")
      (ja "キャンセル")
      (hu "Mégse")))
    ("commonClose"
     ((en "Close")
      (ja "閉じる")
      (hu "Bezárás")))
    ("commonOpen"
     ((en "Open")
      (ja "開く")
      (hu "Megnyitás")))
    ("commonOk"
     ((en "OK")
      (ja "了解")
      (hu "Rendben")))
    ("commonSave"
     ((en "Save")
      (ja "保存")
      (hu "Mentése")))
    ("commonYes"
     ((en "Yes")
      (ja "はい")
      (hu "Igen")))
    ("connectionError"
     ((en "Connection error or invalid link.\\nThe copied text is \\\"{copiedText}\\\"."
          ,(make-description "Error message shown when a connection fails or the URL is invalid.")
          ,(make-variables
            (set-variable "copiedText" #:type "String")))
      (ja "接続エラー、または無効なリンクです。\\nコピーされたテキスト: \\\"{copiedText}\\\"")
      (hu "Csatlakozási hiba vagy érvénytelen hivatkozás.\\nA másolt szöveg: \\\"{copiedText}\\\".")))
    ("contentsBackupLabel"
     ((en "Backup Contents")
      (ja "コンテンツのバックアップ")
      (hu "Tartalomak biztonsági mentése")))
    ("contentsCopySuccessMessage"
     ((en "Contents copied to the clipboard")
      (ja "コンテンツをクリップボードにコピーしました")
      (hu "Tartalomak a vágólapra másolva")))
    ("contentsBackupCancelledMessage"
     ((en "Contents backup cancelled.")
      (ja "コンテンツのバックアップをキャンセルしました。")
      (hu "A tartalmak biztonsági mentése megszakítva.")))
    ("contentsBackupCompletedMessage"
     ((en "Contents backup completed.")
      (ja "コンテンツのバックアップを完了しました。")
      (hu "A tartalmak biztonsági mentése elkészült.")))
    ("contentsBackupErrorMessage"
     ((en "Failed to backup contents: {error}"
          ,(make-description "Error message shown when Backing up contents fails.")
          ,(make-variables
            (set-variable "error" #:type "String")))
      (ja "コンテンツのバックアップが失敗しました：{error}")
      (hu "Nem sikerült a tartalomak biztonsági mentése: {error}")))
    ("contentListLabel"
     ((en "Content List")
      (ja "コンテンツ一覧")
      (hu "Tartalomlista")))
    ("contentsRestoreLabel"
     ((en "Restore contents")
      (ja "コンテンツのリストア")
      (hu "Tartalomak visszaállítása")))
    ("contentsRestoreErrorMessage"
     ((en "failed to import contents: {error}"
          ,(make-description "Error message shown when importing contents fails.")
          ,(make-variables
            (set-variable "error" #:type "String")))
      (ja "コンテンツをリストアできませんでした：{error}")
      (hu "Nem sikerült a tartalomak visszaállítása: {error}")))
    ("contentsRestoreSuccessMessage"
     ((en "Contents restored successfully: {count, plural, zero {no contents} one {1 content} other {{count} contents}}"
          ,(make-description "Formated text for word count.")
          ,(make-variables
            (set-variable "count" #:type "int")))
      (ja "コンテンツを復元しました：{count}個")
      (hu "Tartalomak sikeresen visszaállítva: {count} tartalom")))
    ("contentsViewedLabel"
     ((en "Contents Viewed")
      (ja "閲覧コンテンツ")
      (hu "Megtekintett tartalmak")))
    ("darkModeLabel"
     ((en "Dark Mode")
      (ja "ダークモード")
      (hu "Sötét mód")))
    ("deleteLabel"
     ((en "Delete")
      (ja "削除")
      (hu "Törlés")))
    ("editTitleLabel"
     ((en "Edit title")
      (ja "タイトル編集")
      (hu "Cím szerkesztése")))
    ("errorLabel"
     ((en "Error")
      (ja "エラー")
      (hu "Hiba")))
    ("eulaDescription"
     ((en "Terms of use for this app")
      (ja "このアプリの利用規約")
      (hu "Az alkalmazás használati feltételei")))
    ("eulaDialogTitle"
     ((en "Terms of Use (EULA)")
      (ja "利用規約（EULA）")
      (hu "Felhasználási feltételek (EULA)")))
    ("eulaLabel"
     ((en "End User License Agreement")
      (ja "エンドユーザー使用許諾契約（EULA）")
      (hu "Végfelhasználói licencszerződés (EULA)")))
    ("eulaText"
     ((en "END USER LICENSE AGREEMENT (EULA)\\n\\n1. ACCEPTANCE OF TERMS\\nBy downloading, installing, or using this application (\\\"Application\\\"), you agree to be bound by the terms of this End User License Agreement (\\\"EULA\\\"). If you do not agree to these terms, do not install or use the Application.\\n\\n2. LICENSE GRANT\\nWITHLET11 grants you a limited, non-exclusive, non-transferable, revocable license to download, install, and use the Application on devices that you own or control.\\n\\n3. COPYRIGHT & PROPRIETARY ASSETS\\nThe source code of the Application is licensed under the MIT License. The MIT License applies to the source code only. The application icon, custom graphics, images, user interface designs, and other original visual assets are not covered by the MIT License and remain the property of WITHLET11.\\nThe original application name and other branding elements are not licensed under the MIT License. This EULA does not grant permission to reuse these proprietary assets or the original application name when redistributing the Application or a modified version of it.\\n\\n4. RESTRICTIONS\\nYou agree NOT to:\\na) Re-upload or redistribute the Application, or a modified version of it, using the original application name, app icon, or proprietary visual assets in a manner that suggests it is the original Application or an authorized version.\\nb) Remove, alter, or obscure any copyright notices or proprietary markings within the Application.\\n\\n5. DISCLAIMER OF WARRANTY & LIMITATION OF LIABILITY\\nTHE APPLICATION IS PROVIDED \\\"AS IS\\\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. THE DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING FROM THE USE OR INABILITY TO USE THE APPLICATION. TOTAL LIABILITY SHALL NOT EXCEED THE AMOUNT PAID BY YOU FOR THE APPLICATION.\\n\\n6. CONTACT INFORMATION\\nFor questions regarding this EULA, please contact: withlet11@gmail.com")
      (ja "エンドユーザー使用許諾契約（EULA）\\n\\n1. 規約への同意\\n本アプリケーション（以下「本アプリ」）をダウンロード、インストール、または使用することにより、お客様は本エンドユーザー使用許諾契約（以下「本EULA」）の規約に同意したものとします。これらの規約に同意されない場合は、本アプリをインストールまたは使用しないでください。\\n\\n2. ライセンスの許諾\\nWITHLET11は、お客様が所有または管理するデバイスに本アプリをダウンロード、インストール、および使用するための、限定的、非独占的、譲渡不能かつ取消可能なライセンスをお客様に許諾します。\\n\\n3. 著作権および独自アセット\\n本アプリのソースコードはMIT Licenseに基づいてライセンスされています。MIT Licenseはソースコードのみに適用されます。アプリケーションアイコン、カスタムグラフィック、画像、ユーザーインターフェースデザイン、その他のオリジナルのビジュアルアセットはMIT Licenseの対象ではなく、WITHLET11に帰属します。\\n\\n本アプリのオリジナルの名称およびその他のブランド要素は、MIT Licenseに基づくライセンスの対象ではありません。本EULAは、本アプリまたはその改変版を再配布する際に、これらの独自アセットまたは本アプリのオリジナル名称を再利用する許可を与えるものではありません。\\n\\n4. 制限事項\\nお客様は、以下の行為を行わないことに同意するものとします。\\na) オリジナルのアプリケーション名称、アプリアイコン、または独自のビジュアルアセットを使用し、本アプリまたはその改変版がオリジナルの本アプリまたは承認されたバージョンであるかのように見せる形で、本アプリまたはその改変版を第三者のアプリストアまたはウェブサイトに再アップロードまたは再配布すること。\\nb) 本アプリ内の著作権表示または独自の権利表示を削除、変更、または不明瞭にすること。\\n\\n5. 保証の否認および責任の制限\\n本アプリは「現状有姿」で提供され、明示または黙示を問わず、いかなる種類の保証もありません。本アプリの使用または使用不能に起因する直接的、間接的、付随的、または結果的な損害について、開発者は責任を負わないものとします。開発者の総責任額は、お客様が本アプリのために支払った金額を超えないものとします。\\n\\n6. 連絡先\\n本EULAに関するお問い合わせは、以下までご連絡ください：withlet11@gmail.com")
      (hu "VÉGFELHASZNÁLÓI LICENCSZERZŐDÉS (EULA)\\n\\n1. A FELTÉTELEK ELFOGADÁSA\\nAz alkalmazás (a továbbiakban: „Alkalmazás”) letöltésével, telepítésével vagy használatával Ön elfogadja a jelen Végfelhasználói Licencszerződés (a továbbiakban: „EULA”) feltételeit, és magára nézve kötelezőnek ismeri el azokat. Ha nem ért egyet ezekkel a feltételekkel, ne telepítse és ne használja az Alkalmazást.\\n\\n2. LICENC MEGADÁSA\\nA WITHLET11 korlátozott, nem kizárólagos, nem átruházható és visszavonható licencet biztosít Önnek az Alkalmazás letöltésére, telepítésére és használatára az Ön tulajdonában vagy ellenőrzése alatt álló eszközökön.\\n\\n3. SZERZŐI JOG ÉS SAJÁT TULAJDONÚ ELEMEK\\nAz Alkalmazás forráskódja az MIT License feltételei szerint van licencelve. Az MIT License kizárólag a forráskódra vonatkozik. Az alkalmazásikon, az egyedi grafikák, a képek, a felhasználói felület tervei és az egyéb eredeti vizuális elemek nem tartoznak az MIT License hatálya alá, és a WITHLET11 tulajdonát képezik.\\n\\nAz Alkalmazás eredeti neve és egyéb márkaelemei nem tartoznak az MIT License hatálya alá. A jelen EULA nem ad engedélyt ezen saját tulajdonú elemek vagy az Alkalmazás eredeti nevének újrafelhasználására az Alkalmazás vagy annak módosított változatának újraterjesztése során.\\n\\n4. KORLÁTOZÁSOK\\nÖn vállalja, hogy NEM:\\na) tölti fel újra vagy terjeszti újra az Alkalmazást vagy annak módosított változatát harmadik felek alkalmazás-áruházaiban vagy webhelyein az eredeti alkalmazásnév, alkalmazásikon vagy saját tulajdonú vizuális elemek használatával oly módon, amely azt a látszatot kelti, hogy az az eredeti Alkalmazás vagy annak engedélyezett változata;\\nb) távolítja el, módosítja vagy teszi olvashatatlanná az Alkalmazásban található szerzői jogi vagy egyéb tulajdonjogi megjegyzéseket.\\n\\n5. GARANCIANYÚJTÁS KIZÁRÁSA ÉS FELELŐSSÉGKORLÁTOZÁS\\nAZ ALKALMAZÁS „JELEN ÁLLAPOTÁBAN” KERÜL BIZTOSÍTÁSRA, BÁRMILYEN KIFEJEZETT VAGY HALLGATÓLAGOS GARANCIA NÉLKÜL. A FEJLESZTŐ NEM FELELŐS AZ ALKALMAZÁS HASZNÁLATÁBÓL VAGY HASZNÁLATÁNAK LEHETETLENSÉGÉBŐL EREDŐ KÖZVETLEN, KÖZVETETT, JÁRULÉKOS VAGY KÖVETKEZMÉNYES KÁROKÉRT. A FEJLESZTŐ TELJES FELELŐSSÉGE NEM HALADHATJA MEG AZ ALKALMAZÁSÉRT ÖN ÁLTAL FIZETETT ÖSSZEGET.\\n\\n6. KAPCSOLATTARTÁSI ADATOK\\nA jelen EULA-val kapcsolatos kérdésekkel kapcsolatban az alábbi e-mail-címen léphet kapcsolatba velünk: withlet11@gmail.com")))
    ("exactMatchLabel"
     ((en "Exact match")
      (ja "完全一致")
      (hu "Pontos egyezés")))
    ("existingLinkOpenConfirmation"
     ((en "This link has already been added. Do you want to open it?")
      (ja "このリンクはすでに追加されています。開きますか？")
      (hu "Ez a hivatkozás már hozzá van adva. Megnyitja?")))
    ("favoriteCannotDeleteConfirmation"
     ((en "This link is a favorite. To delete it, please remove it from your favorites first.")
      (ja "このリンクはお気に入りに登録されています。削除する場合は、先にお気に入りから外してください。")
      (hu "Ez a link a kedvencek között van. A törléshez először távolítsa el a kedvencek közül.")))
    ("favoritesLabel"
     ((en "Favorites")
      (ja "お気に入り")
      (hu "Kedvencek")))
    ("fieldAlreadyFilledMessage"
     ((en "The field is already filled.")
      (ja "空欄は入力済みです")
      (hu "A mező már ki van töltve.")))
    ("fileNotSelectedMessage"
     ((en "No file selected.")
      (ja "ファイルが選択されていません。")
      (hu "Nincs fájl kiválasztva.")))
    ("fontSizeLabel"
     ((en "Font Size")
      (ja "フォントサイズ")
      (hu "Betűméret")))
    ("fontSizeLarge"
     ((en "Large")
      (ja "大")
      (hu "Nagy")))
    ("fontSizeMedium"
     ((en "Medium")
      (ja "中")
      (hu "Közepes")))
    ("fontSizeSmall"
     ((en "Small")
      (ja "小")
      (hu "Kicsi")))
    ("fontSizeXLarge"
     ((en "X-Large")
      (ja "特大")
      (hu "Extra nagy")))
    ("freeVersionDescription"
     ((en "Limited activity history\\nRead-aloud unavailable")
      (ja "履歴に制限あり・読み上げ利用不可")
      (hu "Korlátozott előzmények\\nFelolvasás nem érhető el")))
    ("freeVersionLabel"
     ((en "Free version")
      (ja "無料版")
      (hu "Ingyenes verzió")))
    ("fullVersionDescription"
     ((en "Unlimited activity history\\nRead-aloud available")
      (ja "履歴無制限・読み上げ利用可能")
      (hu "Korlátlan előzmények\\nFelolvasás elérhető")))
    ("fullVersionLabel"
     ((en "Full version")
      (ja "完全版")
      (hu "Teljes verzió")))
    ("hiddenPartDescription"
     ((en "Choose the part of each word to hide.")
      (ja "非表示にする単語の部分を選択します。")
      (hu "Válassza ki, hogy a szavak melyik részét szeretné elrejteni.")))
    ("hiddenPartLabel"
     ((en "Hidden Part")
      (ja "非表示部分")
      (hu "Rejtett rész")))
    ("importCount"
     ((en "Imported {successCount}"
          ,(make-description "Error message shown when counting imported links fails.")
          ,(make-variables
            (set-variable "successCount" #:type "int")))
      (ja "{successCount}件インポート")
      (hu "{successCount} hivatkozás importálva")))
    ("importSummary"
     ((en "Already exists: {existsCount}\\nNo paragraphs: {noParagraphCount}\\nInvalid Link: {invalidUrlCount}\\nError: {errorCount}"
          ,(make-description "Notification shown after links are imported.")
          ,(make-variables
            (set-variable "existsCount" #:type "int")
            (set-variable "noParagraphCount" #:type "int")
            (set-variable "invalidUrlCount" #:type "int")
            (set-variable "errorCount" #:type "int")))
      (ja "既存：{existsCount}\\n段落なし：{noParagraphCount}\\n無効なリンク：{invalidUrlCount}\\nエラー：{errorCount}")
      (hu "Már létezik: {existsCount}\\nNincs bekezdés: {noParagraphCount}\\nÉrvénytelen Hivatkozás: {invalidUrlCount}\\nHiba: {errorCount}")))
    ("invalidUrlLabel"
     ((en "Invalid Link")
      (ja "無効なリンク")
      (hu "Érvénytelen hivatkozás")))
    ("languageLabel"
     ((en "Language")
      (ja "言語")
      (hu "Nyelv")))
    ("licensesDescription"
     ((en "Third-party software notices")
      (ja "第三者ソフトウェアに関する通知")
      (hu "Harmadik féltől származó szoftverekkel kapcsolatos tájékoztatás")))
    ("licensesLabel"
     ((en "Open Source Licenses")
      (ja "オープンソースライセンス")
      (hu "Nyílt forráskódú licencek")))
    ("linkAdditionSuccessMessage"
     ((en "Link added successfully!"
          ,(make-description "Success message shown after adding a link successful."))
      (ja "リンクを追加しました")
      (hu "Hivatkozás sikeresen hozzáadva!")))
    ("noCopiedUrlLabel"
     ((en "No copied link")
      (ja "リンクがコピーされていません")
      (hu "Nincs kimásolt hivatkozás")))
    ("noTextLabel"
     ((en "No text")
      (ja "テキストなし")
      (hu "Nincs szöveg")))
    ("noTitle"
     ((en "No title")
      (ja "タイトル無し")
      (hu "Cím nélkül")))
    ("notContainsParagraphMessage"
     ((en "No paragraph text was found at the copied link.\\nPlease try a different link."
          ,(make-description "Notification shown when no paragraphs at the copied link."))
      (ja "コピーしたリンクの参照先には段落テキストが含まれていません。\\n別のURLでお試しください。")
      (hu "A másolt hivatkozáson nem található bekezdésszöveg.\\nKérjük, próbáljon meg egy másik hivatkozást.")))
    ("openInBrowserDescription"
     ((en "Open the current page in the browser."
          ,(make-description "Description of open in browser button."))
      (ja "現在のページをブラウザで開きます。")
      (hu "Az aktuális oldalt megnyitja a böngészőben.")))
    ("openInBrowserLabel"
     ((en "Open in browser")
      (ja "ブラウザで開く")
      (hu "Megnyitás böngészőben")))
    ("openPageDescription"
     ((en "Copy the link from your browser's address bar and click here to open the page."
          ,(make-description "Description of open page button."))
      (ja "ブラウザのアドレスバーからリンクをコピーして、ここをクリックするとページが開きます。")
      (hu "Másolja ki a hivatkozást a böngésző címsorából, majd kattintson ide az oldal megnyitásához.")))
    ("openPageLabel"
     ((en "Open page")
      (ja "ページを開く")
      (hu "Oldal megnyitása")))
    ("pageLoadFailMessage"
     ((en "Failed to load the page"
          ,(make-description "Error message shown when loading page fails."))
      (ja "ページの読み込みに失敗しました")
      (hu "Nem sikerült az oldal betöltése")))
    ("pasteButton"
     ((en "Paste")
      (ja "貼り付け")
      (hu "Beillesztés")))
    ("readNavButton"
     ((en "Read")
      (ja "読む")
      (hu "Olvasás")))
    ("refreshCacheDescription"
     ((en "Refresh the cache of the current page."
          ,(make-description "Description of refresh cache button."))
      (ja "現在のページのキャッシュを更新します。")
      (hu "Frissíti az aktuális oldal gyorsítótárát.")))
    ("refreshCacheLabel"
     ((en "Refresh Cache")
      (ja "キャッシュ更新")
      (hu "Gyorsítótár frissítése")))
    ("restoreButton"
     ((en "Restore")
      (ja "復元")
      (hu "Visszaállítása")))
    ("restoreOriginalButton"
     ((en "Restore original")
      (ja "オリジナルに戻す")
      (hu "Eredeti visszaállítása")))
    ("searchLabel"
     ((en "Search")
      (ja "検索")
      (hu "Keresés")))
    ("speechRateFast"
     ((en "Fast")
      (ja "速い")
      (hu "Gyors")))
    ("speechRateFastest"
     ((en "Fastest")
      (ja "最速")
      (hu "Leggyorsabb")))
    ("speechRateLabel"
     ((en "Speech rate")
      (ja "読み上げ速度")
      (hu "Felolvasási sebesség")))
    ("speechRateMedium"
     ((en "Medium")
      (ja "標準")
      (hu "Közepes")))
    ("speechRateSlow"
     ((en "Slow")
      (ja "遅い")
      (hu "Lassú")))
    ("speechVolumeLabel"
     ((en "Speech volume")
      (ja "読み上げ音量")
      (hu "Felolvasás hangereje")))
    ("speechVolumeLow"
     ((en "Low")
      (ja "小")
      (hu "Alacsony")))
    ("speechVolumeMax"
     ((en "Max")
      (ja "最大")
      (hu "Maximum")))
    ("speechVolumeMedium"
     ((en "Medium")
      (ja "中")
      (hu "Közepes")))
    ("speechVolumeMute"
     ((en "Mute")
      (ja "消音")
      (hu "Némítás")))
    ("unableToPricingMessage"
     ((en "Unable to load product pricing.")
      (ja "商品の価格を読み込めません。")
      (hu "Nem sikerült betölteni a termék árát.")))
    ("urlCopyRequest"
     ((en "Please copy the link from your browser's address bar."
          ,(make-description "Request message when adding a link."))
      (ja "ブラウザのアドレスバーからリンクをコピーしてください。" )
      (hu "Kérjük, másolja ki a hivatkozást a böngésző címsorából.")))
    ("urlRequestMessage"
     ((en "Please add a link")
      (ja "リンクを追加してください")
      (hu "Kérjük, adjon meg egy hivatkozást")))
    ("viewPlainTextDescription"
     ((en "View the current page as plain text."
          ,(make-description "Description of view plain text button."))
      (ja "現在のページをプレーンテキストで表示します。")
      (hu "Az aktuális oldal megjelenítése egyszerű szövegként.")))
    ("viewPlainTextLabel"
     ((en "View as plain text")
      (ja "プレーンテキストで表示")
      (hu "Megjelenítés egyszerű szövegként")))
    ("wholeWordsLabel"
     ((en "Whole")
      (ja "全体")
      (hu "Teljes")))
    ("wordCount"
     ((en "{count, plural, zero {no words} one {1 word} other {{count} words}}"
          ,(make-description "Formated text for word count.")
          ,(make-variables
            (set-variable "count" #:type "int")))
      (ja "{count}単語")
      (hu "{count} szó")))
    ("wordsEncounteredLabel"
     ((en "Words Encountered")
      (ja "出現単語")
      (hu "Előforduló szavak")))
    ("dateFormatForDailyChart"
     ((en "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))
      (ja "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))
      (hu "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))))
    ("dateFormatForWeeklyChart"
     ((en "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "yMMMMd")
            (set-variable "date2" #:type "DateTime" #:format"yMMMMd")))
      (ja "{date1}〜{date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "yMMMMd")
            (set-variable "date2" #:type "DateTime" #:format "yMMMMd")))
      (hu "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "yMMMMd")
            (set-variable "date2" #:type "DateTime" #:format "yMMMMd")))))
    ("dateFormatForWeeklyChartInSameMonth"
     ((en "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "MMMMd")
            (set-variable "date2" #:type "DateTime" #:format "d")))
      (ja "{date1}〜{date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "M月d" #:isCustomDateFormat #t)
            (set-variable "date2" #:type "DateTime" #:format "d")))
      (hu "{date1}−{date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "MMMM d" #:isCustomDateFormat #t)
            (set-variable "date2" #:type "DateTime" #:format "d." #:isCustomDateFormat #t)))))
    ("dateFormatForWeeklyChartInSameYear"
     ((en "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "MMMMd")
            (set-variable "date2" #:type "DateTime" #:format "MMMMd")))
      (ja "{date1}〜{date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "MMMMd")
            (set-variable "date2" #:type "DateTime" #:format "MMMMd")))
      (hu "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "MMMMd")
            (set-variable "date2" #:type "DateTime" #:format "MMMMd")))))
    ("dateFormatForMonthlyChart"
     ((en "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "yMMMM")))
      (ja "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "yMMMM")))
      (hu "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "yMMMM")))))))


;; ============================================================
;; Processing
;; ============================================================
;; Usage:
;;   racket localize.rkt
;;
;; Run from the directory containing this file.
;;
;; Revision history:
;; - 2026-10-19: Initial version.

(define (create-xml-doc lst lang)
  `("{"
    ,(string-append "  \"@@locale\": \"" (symbol->string lang) "\",")
    ,@(flatten (entry->string (get-entries-with-lang lst lang) 1))
    "}"))

(define (get-entries-with-lang lst lang)
  (filter
   list?
   (map (lambda (entry)
          (let ([key (first entry)] [vals (second entry)])
            (cond [(assq lang vals)
                   => (lambda (val) (cons key (cdr val)))]
                  [else (error "missing localized strings" lang entry)])))
        lst)))

(define (entry->string entries idx)
  (add-delimiter-between
   (map (lambda (x)
          (let ([key (car x)] [content (cadr x)] [attrs (cddr x)])
            (if (null? attrs)
                (string-append (make-string (* 2 idx) #\space) "\""
                               key "\": \"" content "\"")
                `(,(string-append (make-string (* 2 idx) #\space)
                                  "\"" key "\": \"" content "\",")
                  ,(string-append (make-string (* 2 idx) #\space)
                                  "\"@" key "\": {")
                  ,(values->string attrs (add1 idx))
                  ,(string-append (make-string (* 2 idx) #\space)
                                  "}")))))
        entries)))

(define (values->string entries idx)
  (add-delimiter-between
   (map (lambda (x)
          (let ([key (car x)] [val (cdr x)])
            (cond [(list? (car val))
                   `(,(string-append (make-string (* 2 idx) #\space)
                                     "\"" key "\": {")
                     ,(values->string val (add1 idx))
                     ,(string-append (make-string (* 2 idx) #\space)
                                     "}"))]
                  [(string? (car val))
                   (string-append (make-string (* 2 idx) #\space)
                                  "\"" key "\": \"" (car val) "\"")]
                  [else (error "malform" x)])))
        entries)))

(define (add-delimiter-between lst)
  (foldr (lambda (x acc)
           (if (null? acc)
               (list x)
               (cons (add-delimiter-at-end x) acc)))
         '()
         lst))

(define (add-delimiter-at-end x)
  (if (string? x)
      (string-append x ",")
      (let ([r (reverse x)])
        (reverse (cons (add-delimiter-at-end (car r)) (cdr r))))))

(for-each (lambda (x)
            (let ([lang (first x)]
                  [path (second x)])
              (call-with-output-file (string->path path)
                (lambda (out)
                  (for-each (lambda (ln) (displayln ln out))
                            (create-xml-doc value-list lang)))
                #:exists 'replace)))
          lang-list)

(displayln "Completed!")
