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
                    (fr "../lib/l10n/app_fr.arb")
                    (zh "../lib/l10n/app_zh.arb")))

(define value-list
  `(("buyForLabel"
     ((en "Buy for {price}"
          ,(make-variables
            (set-variable "price" #:type "String")))
      (ja "{price}で購入")
      (hu "Vásárlás: {price}")
      (fr "Acheter pour {price}")
      (zh "以 {price} 购买")))
    ("restorePurchasesLabel"
     ((en "Restore Purchases")
      (ja "購入を復元")
      (hu "Vásárlások visszaállítása")
      (fr "Restaurer les achats")
      (zh "恢复购买")))
    ("beginningOfWordsLabel"
     ((en "Beginning")
      (ja "先頭")
      (hu "eleje")
      (fr "Début")
      (zh "开头")))
    ("endOfWordsLabel"
     ((en "End")
      (ja "末尾")
      (hu "vége")
      (fr "Fin")
      (zh "结尾")))
    ("activityBackupCancelledMessage"
     ((en "Activity backup cancelled.")
      (ja "アクティビティのバックアップをキャンセルしました。")
      (hu "A tevékenység biztonsági mentése megszakítva.")
      (fr "Sauvegarde de l’activité annulée.")
      (zh "活动备份已取消。")))
    ("activityBackupCompletedMessage"
     ((en "Activity backup completed.")
      (ja "アクティビティのバックアップを完了しました。")
      (hu "A tevékenység biztonsági mentése elkészült.")
      (fr "Sauvegarde de l’activité terminée.")
      (zh "活动备份已完成。")))
    ("activityBackupLabel"
     ((en "Backup Activity")
      (ja "アクティビティをバックアップ")
      (hu "Tevékenység biztonsági mentése")
      (fr "Sauvegarder l’activité")
      (zh "备份活动记录")))
    ("activityBackupNotFound"
     ((en "Backup file not found: {path}")
      (ja "バックアップファイルが見つかりません: {path}")
      (hu "Mentési fájl nem található: {path}")
      (fr "Fichier de sauvegarde introuvable : {path}")
      (zh "未找到备份文件：{path}")))
    ("activityNavButton"
     ((en "Activity")
      (ja "アクティビティ")
      (hu "Tevékenység")
      (fr "Activité")
      (zh "活动记录")))
    ("activityRestoreErrorMessage"
     ((en "failed to restore activities: {error}"
          ,(make-description "Error message shown when restoring contents fails.")
          ,(make-variables
            (set-variable "error" #:type "String")))
      (ja "アクティビティをリストアできませんでした：{error}")
      (hu "Nem sikerült a tevékenység visszaállítása: {error}")
      (fr "Échec de la restauration des activités : {error}")
      (zh "恢复活动记录失败：{error}")))
    ("activityRestoreLabel"
     ((en "Restore Activity")
      (ja "アクティビティを復元")
      (hu "Tevékenység visszaállítása")
      (fr "Restaurer l’activité")
      (zh "恢复活动记录")))
    ("activityRestoreSuccessMessage"
     ((en "Activity restored successfully: {count, plural, zero {no words} one {1 word} other {{count} words}}"
          ,(make-description "Formated text for word count.")
          ,(make-variables
            (set-variable "count" #:type "int")))
      (ja "アクティビティを復元しました：{count}単語")
      (hu "Tevékenység sikeresen visszaállítva: {count} szó")
      (fr "Activité restaurée : {count, plural, zero {aucun mot} one {1 mot} other {{count} mots}}")
      (zh "活动记录已成功恢复：{count, plural, zero {没有单词} one {1 个单词} other {{count} 个单词}}")))
    ("activityRestoreSuccess"
     ((en "Activity restored successfully")
      (ja "アクティビティを復元しました")
      (hu "Tevékenység sikeresen visszaállítva")
      (fr "Activité restaurée avec succès")
      (zh "活动记录已成功恢复")))
    ("allContentsClearButton"
     ((en "Clear all contents"
          ,(make-description "A label of clear all contents."))
      (ja "すべてのコンテンツの削除")
      (hu "Összes tartalmak törlése")
      (fr "Effacer tout le contenu")
      (zh "清除所有内容")))
    ("allContentsClearConfirmation"
     ((en "Are you sure you want to clear all contents?"
          ,(make-description "Confirmation message shown before clearing all contents."))
      (ja "すべてのコンテンツを削除します。よろしいですか？")
      (hu "Biztosan törli az összes tartalmat?")
      (fr "Voulez-vous vraiment effacer tout le contenu ?")
      (zh "确定要清除所有内容吗？")))
    ("allLanguage"
     ((en "All🌐")
      (ja "すべて🌐")
      (hu "Összes🌐")
      (fr "Toutes🌐")
      (zh "全部🌐")))
    ("alreadyExistsMessage"
     ((en "Already exists")
      (ja "既に存在します")
      (hu "Már létezik")
      (fr "Existe déjà")
      (zh "已存在")))
    ("appLegalese"
     ((en "© 2026 WITHLET11. Source code licensed under the MIT License. Brand & Assets Reserved.")
      (ja "© 2026 WITHLET11. ソースコードはMIT Licenseに基づきます。ブランドおよびアセットは留保されています。")
      (hu "© 2026 WITHLET11. A forráskód az MIT License feltételei szerint használható. A márka és az egyéb elemek jogai fenntartva.")
      (fr "© 2026 WITHLET11. Le code source est distribué sous licence MIT. La marque et les éléments graphiques sont réservés.")
      (zh "© 2026 WITHLET11。源代码采用 MIT 许可证。品牌及素材权利均予保留。")))
    ("appName"
     ((en "ReadBlank")
      (ja "ReadBlank")
      (hu "ReadBlank")
      (fr "ReadBlank")
      (zh "ReadBlank")))
    ("appVersion"
     ((en "1.0.1")
      (ja "1.0.1")
      (hu "1.0.1")
      (fr "1.0.1")
      (zh "1.0.1")))
    ("backupButton"
     ((en "Backup")
      (ja "バックアップ")
      (hu "Mentése")
      (fr "Sauvegarder")
      (zh "备份")))
    ("backupDescription"
     ((en "Backup & Restore")
      (ja "バックアップの作成と復元")
      (hu "Biztonsági mentés és visszaállítás")
      (fr "Sauvegarde et restauration")
      (zh "备份与恢复")))
    ("backupLabel"
     ((en "Backup")
      (ja "バックアップ")
      (hu "Biztonsági mentés")
      (fr "Sauvegarde")
      (zh "备份")))
    ("clipboardEmptyMessage"
     ((en "The clipboard is empty. Please copy the exported data."
          ,(make-description "Error message shown when the clipboard is empty before importing JSON data."))
      (ja "クリップボードが空です。エクスポートデータのコピーが必要です。")
      (hu "A vágólap üres. Kérjük, másolja ki az exportált adatokat.")
      (fr "Le presse-papiers est vide. Veuillez copier les données exportées.")
      (zh "剪贴板为空。请先复制导出的数据。")))
    ("commonCancel"
     ((en "Cancel")
      (ja "キャンセル")
      (hu "Mégse")
      (fr "Annuler")
      (zh "取消")))
    ("commonClose"
     ((en "Close")
      (ja "閉じる")
      (hu "Bezárás")
      (fr "Fermer")
      (zh "关闭")))
    ("commonOpen"
     ((en "Open")
      (ja "開く")
      (hu "Megnyitás")
      (fr "Ouvrir")
      (zh "打开")))
    ("commonOk"
     ((en "OK")
      (ja "了解")
      (hu "Rendben")
      (fr "OK")
      (zh "确定")))
    ("commonSave"
     ((en "Save")
      (ja "保存")
      (hu "Mentése")
      (fr "Enregistrer")
      (zh "保存")))
    ("commonYes"
     ((en "Yes")
      (ja "はい")
      (hu "Igen")
      (fr "Oui")
      (zh "是")))
    ("connectionError"
     ((en "Connection error or invalid link.\\nThe copied text is \\\"{copiedText}\\\"."
          ,(make-description "Error message shown when a connection fails or the URL is invalid.")
          ,(make-variables
            (set-variable "copiedText" #:type "String")))
      (ja "接続エラー、または無効なリンクです。\\nコピーされたテキスト: \\\"{copiedText}\\\"")
      (hu "Csatlakozási hiba vagy érvénytelen hivatkozás.\\nA másolt szöveg: \\\"{copiedText}\\\".")
      (fr "Erreur de connexion ou lien invalide.\\nTexte copié : \\\"{copiedText}\\\".")
      (zh "连接错误或链接无效。\\n复制的文本：\\\"{copiedText}\\\"。")))
    ("contentsBackupLabel"
     ((en "Backup Contents")
      (ja "コンテンツのバックアップ")
      (hu "Tartalomak biztonsági mentése")
      (fr "Sauvegarder le contenu")
      (zh "备份内容")))
    ("contentsCopySuccessMessage"
     ((en "Contents copied to the clipboard")
      (ja "コンテンツをクリップボードにコピーしました")
      (hu "Tartalomak a vágólapra másolva")
      (fr "Contenu copié dans le presse-papiers")
      (zh "内容已复制到剪贴板")))
    ("contentsBackupCancelledMessage"
     ((en "Contents backup cancelled.")
      (ja "コンテンツのバックアップをキャンセルしました。")
      (hu "A tartalmak biztonsági mentése megszakítva.")
      (fr "Sauvegarde du contenu annulée.")
      (zh "内容备份已取消。")))
    ("contentsBackupCompletedMessage"
     ((en "Contents backup completed.")
      (ja "コンテンツのバックアップを完了しました。")
      (hu "A tartalmak biztonsági mentése elkészült.")
      (fr "Sauvegarde du contenu terminée.")
      (zh "内容备份已完成。")))
    ("contentsBackupErrorMessage"
     ((en "Failed to backup contents: {error}"
          ,(make-description "Error message shown when Backing up contents fails.")
          ,(make-variables
            (set-variable "error" #:type "String")))
      (ja "コンテンツのバックアップが失敗しました：{error}")
      (hu "Nem sikerült a tartalomak biztonsági mentése: {error}")
      (fr "Échec de la sauvegarde du contenu : {error}")
      (zh "备份内容失败：{error}")))
    ("contentListLabel"
     ((en "Content List")
      (ja "コンテンツ一覧")
      (hu "Tartalomlista")
      (fr "Liste du contenu")
      (zh "内容列表")))
    ("contentsRestoreLabel"
     ((en "Restore contents")
      (ja "コンテンツのリストア")
      (hu "Tartalomak visszaállítása")
      (fr "Restaurer le contenu")
      (zh "恢复内容")))
    ("contentsRestoreErrorMessage"
     ((en "failed to import contents: {error}"
          ,(make-description "Error message shown when importing contents fails.")
          ,(make-variables
            (set-variable "error" #:type "String")))
      (ja "コンテンツをリストアできませんでした：{error}")
      (hu "Nem sikerült a tartalomak visszaállítása: {error}")
      (fr "Échec de l’importation du contenu : {error}")
      (zh "导入内容失败：{error}")))
    ("contentsRestoreSuccessMessage"
     ((en "Contents restored successfully: {count, plural, zero {no contents} one {1 content} other {{count} contents}}"
          ,(make-description "Formated text for word count.")
          ,(make-variables
            (set-variable "count" #:type "int")))
      (ja "コンテンツを復元しました：{count}個")
      (hu "Tartalomak sikeresen visszaállítva: {count} tartalom")
      (fr "Contenu restauré : {count, plural, zero {aucun élément} one {1 élément} other {{count} éléments}}")
      (zh "内容已成功恢复：{count, plural, zero {没有内容} one {1 项内容} other {{count} 项内容}}")))
    ("contentsViewedLabel"
     ((en "Contents Viewed")
      (ja "閲覧コンテンツ")
      (hu "Megtekintett tartalmak")
      (fr "Contenu consulté")
      (zh "已查看的内容")))
    ("darkModeLabel"
     ((en "Dark Mode")
      (ja "ダークモード")
      (hu "Sötét mód")
      (fr "Mode sombre")
      (zh "深色模式")))
    ("deleteLabel"
     ((en "Delete")
      (ja "削除")
      (hu "Törlés")
      (fr "Supprimer")
      (zh "删除")))
    ("editTitleLabel"
     ((en "Edit title")
      (ja "タイトル編集")
      (hu "Cím szerkesztése")
      (fr "Modifier le titre")
      (zh "编辑标题")))
    ("errorLabel"
     ((en "Error")
      (ja "エラー")
      (hu "Hiba")
      (fr "Erreur")
      (zh "错误")))
    ("eulaDescription"
     ((en "Terms of use for this app")
      (ja "このアプリの利用規約")
      (hu "Az alkalmazás használati feltételei")
      (fr "Conditions d’utilisation de cette application")
      (zh "本应用的使用条款")))
    ("eulaDialogTitle"
     ((en "Terms of Use (EULA)")
      (ja "利用規約（EULA）")
      (hu "Felhasználási feltételek (EULA)")
      (fr "Contrat de licence utilisateur final (EULA)")
      (zh "最终用户许可协议（EULA）")))
    ("eulaLabel"
     ((en "End User License Agreement")
      (ja "エンドユーザー使用許諾契約（EULA）")
      (hu "Végfelhasználói licencszerződés (EULA)")
      (fr "Contrat de licence utilisateur final")
      (zh "最终用户许可协议")))
    ("eulaText"
     ((en "END USER LICENSE AGREEMENT (EULA)\\n\\n1. ACCEPTANCE OF TERMS\\nBy downloading, installing, or using this application (\\\"Application\\\"), you agree to be bound by the terms of this End User License Agreement (\\\"EULA\\\"). If you do not agree to these terms, do not install or use the Application.\\n\\n2. LICENSE GRANT\\nWITHLET11 grants you a limited, non-exclusive, non-transferable, revocable license to download, install, and use the Application on devices that you own or control.\\n\\n3. COPYRIGHT & PROPRIETARY ASSETS\\nThe source code of the Application is licensed under the MIT License. The MIT License applies to the source code only. The application icon, custom graphics, images, user interface designs, and other original visual assets are not covered by the MIT License and remain the property of WITHLET11.\\nThe original application name and other branding elements are not licensed under the MIT License. This EULA does not grant permission to reuse these proprietary assets or the original application name when redistributing the Application or a modified version of it.\\n\\n4. RESTRICTIONS\\nYou agree NOT to:\\na) Re-upload or redistribute the Application, or a modified version of it, using the original application name, app icon, or proprietary visual assets in a manner that suggests it is the original Application or an authorized version.\\nb) Remove, alter, or obscure any copyright notices or proprietary markings within the Application.\\n\\n5. DISCLAIMER OF WARRANTY & LIMITATION OF LIABILITY\\nTHE APPLICATION IS PROVIDED \\\"AS IS\\\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. THE DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING FROM THE USE OR INABILITY TO USE THE APPLICATION. TOTAL LIABILITY SHALL NOT EXCEED THE AMOUNT PAID BY YOU FOR THE APPLICATION.\\n\\n6. CONTACT INFORMATION\\nFor questions regarding this EULA, please contact: withlet11@gmail.com")
      (ja "エンドユーザー使用許諾契約（EULA）\\n\\n1. 規約への同意\\n本アプリケーション（以下「本アプリ」）をダウンロード、インストール、または使用することにより、お客様は本エンドユーザー使用許諾契約（以下「本EULA」）の規約に同意したものとします。これらの規約に同意されない場合は、本アプリをインストールまたは使用しないでください。\\n\\n2. ライセンスの許諾\\nWITHLET11は、お客様が所有または管理するデバイスに本アプリをダウンロード、インストール、および使用するための、限定的、非独占的、譲渡不能かつ取消可能なライセンスをお客様に許諾します。\\n\\n3. 著作権および独自アセット\\n本アプリのソースコードはMIT Licenseに基づいてライセンスされています。MIT Licenseはソースコードのみに適用されます。アプリケーションアイコン、カスタムグラフィック、画像、ユーザーインターフェースデザイン、その他のオリジナルのビジュアルアセットはMIT Licenseの対象ではなく、WITHLET11に帰属します。\\n\\n本アプリのオリジナルの名称およびその他のブランド要素は、MIT Licenseに基づくライセンスの対象ではありません。本EULAは、本アプリまたはその改変版を再配布する際に、これらの独自アセットまたは本アプリのオリジナル名称を再利用する許可を与えるものではありません。\\n\\n4. 制限事項\\nお客様は、以下の行為を行わないことに同意するものとします。\\na) オリジナルのアプリケーション名称、アプリアイコン、または独自のビジュアルアセットを使用し、本アプリまたはその改変版がオリジナルの本アプリまたは承認されたバージョンであるかのように見せる形で、本アプリまたはその改変版を第三者のアプリストアまたはウェブサイトに再アップロードまたは再配布すること。\\nb) 本アプリ内の著作権表示または独自の権利表示を削除、変更、または不明瞭にすること。\\n\\n5. 保証の否認および責任の制限\\n本アプリは「現状有姿」で提供され、明示または黙示を問わず、いかなる種類の保証もありません。本アプリの使用または使用不能に起因する直接的、間接的、付随的、または結果的な損害について、開発者は責任を負わないものとします。開発者の総責任額は、お客様が本アプリのために支払った金額を超えないものとします。\\n\\n6. 連絡先\\n本EULAに関するお問い合わせは、以下までご連絡ください：withlet11@gmail.com")
      (hu "VÉGFELHASZNÁLÓI LICENCSZERZŐDÉS (EULA)\\n\\n1. A FELTÉTELEK ELFOGADÁSA\\nAz alkalmazás (a továbbiakban: „Alkalmazás”) letöltésével, telepítésével vagy használatával Ön elfogadja a jelen Végfelhasználói Licencszerződés (a továbbiakban: „EULA”) feltételeit, és magára nézve kötelezőnek ismeri el azokat. Ha nem ért egyet ezekkel a feltételekkel, ne telepítse és ne használja az Alkalmazást.\\n\\n2. LICENC MEGADÁSA\\nA WITHLET11 korlátozott, nem kizárólagos, nem átruházható és visszavonható licencet biztosít Önnek az Alkalmazás letöltésére, telepítésére és használatára az Ön tulajdonában vagy ellenőrzése alatt álló eszközökön.\\n\\n3. SZERZŐI JOG ÉS SAJÁT TULAJDONÚ ELEMEK\\nAz Alkalmazás forráskódja az MIT License feltételei szerint van licencelve. Az MIT License kizárólag a forráskódra vonatkozik. Az alkalmazásikon, az egyedi grafikák, a képek, a felhasználói felület tervei és az egyéb eredeti vizuális elemek nem tartoznak az MIT License hatálya alá, és a WITHLET11 tulajdonát képezik.\\n\\nAz Alkalmazás eredeti neve és egyéb márkaelemei nem tartoznak az MIT License hatálya alá. A jelen EULA nem ad engedélyt ezen saját tulajdonú elemek vagy az Alkalmazás eredeti nevének újrafelhasználására az Alkalmazás vagy annak módosított változatának újraterjesztése során.\\n\\n4. KORLÁTOZÁSOK\\nÖn vállalja, hogy NEM:\\na) tölti fel újra vagy terjeszti újra az Alkalmazást vagy annak módosított változatát harmadik felek alkalmazás-áruházaiban vagy webhelyein az eredeti alkalmazásnév, alkalmazásikon vagy saját tulajdonú vizuális elemek használatával oly módon, amely azt a látszatot kelti, hogy az az eredeti Alkalmazás vagy annak engedélyezett változata;\\nb) távolítja el, módosítja vagy teszi olvashatatlanná az Alkalmazásban található szerzői jogi vagy egyéb tulajdonjogi megjegyzéseket.\\n\\n5. GARANCIANYÚJTÁS KIZÁRÁSA ÉS FELELŐSSÉGKORLÁTOZÁS\\nAZ ALKALMAZÁS „JELEN ÁLLAPOTÁBAN” KERÜL BIZTOSÍTÁSRA, BÁRMILYEN KIFEJEZETT VAGY HALLGATÓLAGOS GARANCIA NÉLKÜL. A FEJLESZTŐ NEM FELELŐS AZ ALKALMAZÁS HASZNÁLATÁBÓL VAGY HASZNÁLATÁNAK LEHETETLENSÉGÉBŐL EREDŐ KÖZVETLEN, KÖZVETETT, JÁRULÉKOS VAGY KÖVETKEZMÉNYES KÁROKÉRT. A FEJLESZTŐ TELJES FELELŐSSÉGE NEM HALADHATJA MEG AZ ALKALMAZÁSÉRT ÖN ÁLTAL FIZETETT ÖSSZEGET.\\n\\n6. KAPCSOLATTARTÁSI ADATOK\\nA jelen EULA-val kapcsolatos kérdésekkel kapcsolatban az alábbi e-mail-címen léphet kapcsolatba velünk: withlet11@gmail.com")
      (fr "CONTRAT DE LICENCE UTILISATEUR FINAL (EULA)\\n\\n1. ACCEPTATION DES CONDITIONS\\nEn téléchargeant, en installant ou en utilisant cette application (l’« Application »), vous acceptez d’être lié par les conditions du présent contrat de licence utilisateur final (l’« EULA »). Si vous n’acceptez pas ces conditions, n’installez pas et n’utilisez pas l’Application.\\n\\n2. OCTROI DE LICENCE\\nWITHLET11 vous accorde une licence limitée, non exclusive, non transférable et révocable pour télécharger, installer et utiliser l’Application sur les appareils que vous possédez ou contrôlez.\\n\\n3. DROITS D’AUTEUR ET ÉLÉMENTS PROPRIÉTAIRES\\nLe code source de l’Application est distribué sous licence MIT. La licence MIT s’applique uniquement au code source. L’icône de l’application, les graphismes personnalisés, les images, les conceptions de l’interface utilisateur et les autres éléments visuels originaux ne sont pas couverts par la licence MIT et restent la propriété de WITHLET11.\\nLe nom original de l’application et les autres éléments de marque ne sont pas concédés sous licence MIT. Le présent EULA n’autorise pas la réutilisation de ces éléments propriétaires ni du nom original de l’application lors de la redistribution de l’Application ou d’une version modifiée.\\n\\n4. RESTRICTIONS\\nVous acceptez de NE PAS :\\na) téléverser à nouveau ou redistribuer l’Application, ou une version modifiée, en utilisant le nom original de l’application, son icône ou ses éléments visuels propriétaires d’une manière laissant croire qu’il s’agit de l’Application originale ou d’une version autorisée ;\\nb) supprimer, modifier ou masquer les mentions de droits d’auteur ou les indications de propriété figurant dans l’Application.\\n\\n5. EXCLUSION DE GARANTIE ET LIMITATION DE RESPONSABILITÉ\\nL’APPLICATION EST FOURNIE « EN L’ÉTAT », SANS GARANTIE D’AUCUNE SORTE, EXPRESSE OU IMPLICITE. LE DÉVELOPPEUR NE POURRA ÊTRE TENU RESPONSABLE DES DOMMAGES DIRECTS, INDIRECTS, ACCESSOIRES OU CONSÉCUTIFS RÉSULTANT DE L’UTILISATION OU DE L’IMPOSSIBILITÉ D’UTILISER L’APPLICATION. LA RESPONSABILITÉ TOTALE NE POURRA DÉPASSER LE MONTANT QUE VOUS AVEZ PAYÉ POUR L’APPLICATION.\\n\\n6. COORDONNÉES\\nPour toute question concernant le présent EULA, veuillez contacter : withlet11@gmail.com")
      (zh "最终用户许可协议（EULA）\\n\\n1. 接受条款\\n下载、安装或使用本应用程序（以下简称“本应用”），即表示您同意遵守本最终用户许可协议（以下简称“本 EULA”）的条款。如果您不同意这些条款，请勿安装或使用本应用。\\n\\n2. 许可授予\\nWITHLET11 授予您一项有限的、非独占的、不可转让且可撤销的许可，允许您在自己拥有或控制的设备上下载、安装和使用本应用。\\n\\n3. 版权及专有资产\\n本应用的源代码依据 MIT 许可证授权。MIT 许可证仅适用于源代码。应用图标、自定义图形、图像、用户界面设计及其他原创视觉素材均不受 MIT 许可证约束，仍归 WITHLET11 所有。\\n本应用的原始名称及其他品牌元素不属于 MIT 许可证的授权范围。本 EULA 不授予您在重新分发本应用或其修改版本时重复使用这些专有素材或本应用原始名称的权限。\\n\\n4. 限制\\n您同意不会：\\na) 使用原始应用名称、应用图标或专有视觉素材，以可能使他人误认为其为原版应用或获授权版本的方式，重新上传或分发本应用或其修改版本；\\nb) 删除、修改或遮盖本应用中的任何版权声明或专有权利标记。\\n\\n5. 免责声明及责任限制\\n本应用按“现状”提供，不作任何明示或默示的保证。对于因使用或无法使用本应用而产生的任何直接、间接、附带或后果性损害，开发者均不承担责任。开发者承担的全部责任不超过您为本应用支付的金额。\\n\\n6. 联系方式\\n如对本 EULA 有任何疑问，请联系：withlet11@gmail.com")))
    ("exactMatchLabel"
     ((en "Exact match")
      (ja "完全一致")
      (hu "Pontos egyezés")
      (fr "Correspondance exacte")
      (zh "完全匹配")))
    ("existingLinkOpenConfirmation"
     ((en "This link has already been added. Do you want to open it?")
      (ja "このリンクはすでに追加されています。開きますか？")
      (hu "Ez a hivatkozás már hozzá van adva. Megnyitja?")
      (fr "Ce lien a déjà été ajouté. Voulez-vous l’ouvrir ?")
      (zh "此链接已添加。是否打开？")))
    ("favoriteCannotDeleteConfirmation"
     ((en "This link is a favorite. To delete it, please remove it from your favorites first.")
      (ja "このリンクはお気に入りに登録されています。削除する場合は、先にお気に入りから外してください。")
      (hu "Ez a link a kedvencek között van. A törléshez először távolítsa el a kedvencek közül.")
      (fr "Ce lien est dans les favoris. Pour le supprimer, veuillez d’abord le retirer des favoris.")
      (zh "此链接已加入收藏夹。若要删除，请先将其从收藏夹中移除。")))
    ("favoritesLabel"
     ((en "Favorites")
      (ja "お気に入り")
      (hu "Kedvencek")
      (fr "Favoris")
      (zh "收藏夹")))
    ("fieldAlreadyFilledMessage"
     ((en "The field is already filled.")
      (ja "空欄は入力済みです")
      (hu "A mező már ki van töltve.")
      (fr "Le champ est déjà rempli.")
      (zh "此字段已填写。")))
    ("fileNotSelectedMessage"
     ((en "No file selected.")
      (ja "ファイルが選択されていません。")
      (hu "Nincs fájl kiválasztva.")
      (fr "Aucun fichier sélectionné.")
      (zh "未选择文件。")))
    ("fontSizeLabel"
     ((en "Font Size")
      (ja "フォントサイズ")
      (hu "Betűméret")
      (fr "Taille de police")
      (zh "字体大小")))
    ("fontSizeLarge"
     ((en "Large")
      (ja "大")
      (hu "Nagy")
      (fr "Grande")
      (zh "大")))
    ("fontSizeMedium"
     ((en "Medium")
      (ja "中")
      (hu "Közepes")
      (fr "Moyenne")
      (zh "中")))
    ("fontSizeSmall"
     ((en "Small")
      (ja "小")
      (hu "Kicsi")
      (fr "Petite")
      (zh "小")))
    ("fontSizeXLarge"
     ((en "X-Large")
      (ja "特大")
      (hu "Extra nagy")
      (fr "Très grande")
      (zh "特大")))
    ("freeVersionDescription"
     ((en "Limited activity history\\nRead-aloud unavailable")
      (ja "履歴に制限あり・読み上げ利用不可")
      (hu "Korlátozott előzmények\\nFelolvasás nem érhető el")
      (fr "Historique des activités limité\\nLecture à voix haute indisponible")
      (zh "活动记录数量有限\\n无法使用朗读功能")))
    ("freeVersionLabel"
     ((en "Free version")
      (ja "無料版")
      (hu "Ingyenes verzió")
      (fr "Version gratuite")
      (zh "免费版")))
    ("fullVersionDescription"
     ((en "Unlimited activity history\\nRead-aloud available")
      (ja "履歴無制限・読み上げ利用可能")
      (hu "Korlátlan előzmények\\nFelolvasás elérhető")
      (fr "Historique des activités illimité\\nLecture à voix haute disponible")
      (zh "活动记录数量不限\\n可使用朗读功能")))
    ("fullVersionLabel"
     ((en "Full version")
      (ja "完全版")
      (hu "Teljes verzió")
      (fr "Version complète")
      (zh "完整版")))
    ("hiddenPartDescription"
     ((en "Choose the part of each word to hide.")
      (ja "非表示にする単語の部分を選択します。")
      (hu "Válassza ki, hogy a szavak melyik részét szeretné elrejteni.")
      (fr "Choisissez la partie de chaque mot à masquer.")
      (zh "选择要隐藏每个单词的哪一部分。")))
    ("hiddenPartLabel"
     ((en "Hidden Part")
      (ja "非表示部分")
      (hu "Rejtett rész")
      (fr "Partie masquée")
      (zh "隐藏部分")))
    ("importCount"
     ((en "Imported {successCount}"
          ,(make-description "Error message shown when counting imported links fails.")
          ,(make-variables
            (set-variable "successCount" #:type "int")))
      (ja "{successCount}件インポート")
      (hu "{successCount} hivatkozás importálva")
      (fr "{successCount} importés")
      (zh "已导入 {successCount} 项")))
    ("importSummary"
     ((en "Already exists: {existsCount}\\nNo paragraphs: {noParagraphCount}\\nInvalid Link: {invalidUrlCount}\\nError: {errorCount}"
          ,(make-description "Notification shown after links are imported.")
          ,(make-variables
            (set-variable "existsCount" #:type "int")
            (set-variable "noParagraphCount" #:type "int")
            (set-variable "invalidUrlCount" #:type "int")
            (set-variable "errorCount" #:type "int")))
      (ja "既存：{existsCount}\\n段落なし：{noParagraphCount}\\n無効なリンク：{invalidUrlCount}\\nエラー：{errorCount}")
      (hu "Már létezik: {existsCount}\\nNincs bekezdés: {noParagraphCount}\\nÉrvénytelen Hivatkozás: {invalidUrlCount}\\nHiba: {errorCount}")
      (fr "Déjà présents : {existsCount}\\nSans paragraphe : {noParagraphCount}\\nLien invalide : {invalidUrlCount}\\nErreurs : {errorCount}")
      (zh "已存在：{existsCount}\\n没有段落：{noParagraphCount}\\n无效链接：{invalidUrlCount}\\n错误：{errorCount}")))
    ("invalidUrlLabel"
     ((en "Invalid Link")
      (ja "無効なリンク")
      (hu "Érvénytelen hivatkozás")
      (fr "Lien invalide")
      (zh "无效链接")))
    ("languageLabel"
     ((en "Language")
      (ja "言語")
      (hu "Nyelv")
      (fr "Langue")
      (zh "语言")))
    ("licensesDescription"
     ((en "Third-party software notices")
      (ja "第三者ソフトウェアに関する通知")
      (hu "Harmadik féltől származó szoftverekkel kapcsolatos tájékoztatás")
      (fr "Mentions relatives aux logiciels tiers")
      (zh "第三方软件声明")))
    ("licensesLabel"
     ((en "Open Source Licenses")
      (ja "オープンソースライセンス")
      (hu "Nyílt forráskódú licencek")
      (fr "Licences des logiciels libres")
      (zh "开源许可证")))
    ("linkAdditionSuccessMessage"
     ((en "Link added successfully!"
          ,(make-description "Success message shown after adding a link successful."))
      (ja "リンクを追加しました")
      (hu "Hivatkozás sikeresen hozzáadva!")
      (fr "Lien ajouté avec succès !")
      (zh "链接已成功添加！")))
    ("noCopiedUrlLabel"
     ((en "No copied link")
      (ja "リンクがコピーされていません")
      (hu "Nincs kimásolt hivatkozás")
      (fr "Aucun lien copié")
      (zh "没有复制的链接")))
    ("noTextLabel"
     ((en "No text")
      (ja "テキストなし")
      (hu "Nincs szöveg")
      (fr "Aucun texte")
      (zh "没有文本")))
    ("noTitle"
     ((en "No title")
      (ja "タイトル無し")
      (hu "Cím nélkül")
      (fr "Sans titre")
      (zh "无标题")))
    ("notContainsParagraphMessage"
     ((en "No paragraph text was found at the copied link.\\nPlease try a different link."
          ,(make-description "Notification shown when no paragraphs at the copied link."))
      (ja "コピーしたリンクの参照先には段落テキストが含まれていません。\\n別のURLでお試しください。")
      (hu "A másolt hivatkozáson nem található bekezdésszöveg.\\nKérjük, próbáljon meg egy másik hivatkozást.")
      (fr "Aucun texte de paragraphe n’a été trouvé à l’adresse copiée.\\nVeuillez essayer un autre lien.")
      (zh "复制的链接页面中未找到段落文本。\\n请尝试其他链接。")))
    ("openInBrowserDescription"
     ((en "Open the current page in the browser."
          ,(make-description "Description of open in browser button."))
      (ja "現在のページをブラウザで開きます。")
      (hu "Az aktuális oldalt megnyitja a böngészőben.")
      (fr "Ouvrir la page actuelle dans le navigateur.")
      (zh "在浏览器中打开当前页面。")))
    ("openInBrowserLabel"
     ((en "Open in browser")
      (ja "ブラウザで開く")
      (hu "Megnyitás böngészőben")
      (fr "Ouvrir dans le navigateur")
      (zh "在浏览器中打开")))
    ("openPageDescription"
     ((en "Copy the link from your browser's address bar and click here to open the page."
          ,(make-description "Description of open page button."))
      (ja "ブラウザのアドレスバーからリンクをコピーして、ここをクリックするとページが開きます。")
      (hu "Másolja ki a hivatkozást a böngésző címsorából, majd kattintson ide az oldal megnyitásához.")
      (fr "Copiez le lien depuis la barre d’adresse de votre navigateur, puis cliquez ici pour ouvrir la page.")
      (zh "从浏览器地址栏复制链接，然后点击此处打开页面。")))
    ("openPageLabel"
     ((en "Open page")
      (ja "ページを開く")
      (hu "Oldal megnyitása")
      (fr "Ouvrir la page")
      (zh "打开页面")))
    ("pageLoadFailMessage"
     ((en "Failed to load the page"
          ,(make-description "Error message shown when loading page fails."))
      (ja "ページの読み込みに失敗しました")
      (hu "Nem sikerült az oldal betöltése")
      (fr "Échec du chargement de la page")
      (zh "页面加载失败")))
    ("pasteButton"
     ((en "Paste")
      (ja "貼り付け")
      (hu "Beillesztés")
      (fr "Coller")
      (zh "粘贴")))
    ("readNavButton"
     ((en "Read")
      (ja "読む")
      (hu "Olvasás")
      (fr "Lire")
      (zh "阅读")))
    ("refreshCacheDescription"
     ((en "Refresh the cache of the current page."
          ,(make-description "Description of refresh cache button."))
      (ja "現在のページのキャッシュを更新します。")
      (hu "Frissíti az aktuális oldal gyorsítótárát.")
      (fr "Actualiser le cache de la page actuelle.")
      (zh "刷新当前页面的缓存。")))
    ("refreshCacheLabel"
     ((en "Refresh Cache")
      (ja "キャッシュ更新")
      (hu "Gyorsítótár frissítése")
      (fr "Actualiser le cache")
      (zh "刷新缓存")))
    ("restoreButton"
     ((en "Restore")
      (ja "復元")
      (hu "Visszaállítása")
      (fr "Restaurer")
      (zh "恢复")))
    ("restoreOriginalButton"
     ((en "Restore original")
      (ja "オリジナルに戻す")
      (hu "Eredeti visszaállítása")
      (fr "Rétablir l’original")
      (zh "恢复原始内容")))
    ("searchLabel"
     ((en "Search")
      (ja "検索")
      (hu "Keresés")
      (fr "Rechercher")
      (zh "搜索")))
    ("speechRateFast"
     ((en "Fast")
      (ja "速い")
      (hu "Gyors")
      (fr "Rapide")
      (zh "快")))
    ("speechRateFastest"
     ((en "Fastest")
      (ja "最速")
      (hu "Leggyorsabb")
      (fr "Le plus rapide")
      (zh "最快")))
    ("speechRateLabel"
     ((en "Speech rate")
      (ja "読み上げ速度")
      (hu "Felolvasási sebesség")
      (fr "Vitesse de lecture")
      (zh "朗读速度")))
    ("speechRateMedium"
     ((en "Medium")
      (ja "標準")
      (hu "Közepes")
      (fr "Moyenne")
      (zh "中")))
    ("speechRateSlow"
     ((en "Slow")
      (ja "遅い")
      (hu "Lassú")
      (fr "Lente")
      (zh "慢")))
    ("speechVolumeLabel"
     ((en "Speech volume")
      (ja "読み上げ音量")
      (hu "Felolvasás hangereje")
      (fr "Volume de la lecture")
      (zh "朗读音量")))
    ("speechVolumeLow"
     ((en "Low")
      (ja "小")
      (hu "Alacsony")
      (fr "Faible")
      (zh "低")))
    ("speechVolumeMax"
     ((en "Max")
      (ja "最大")
      (hu "Maximum")
      (fr "Maximum")
      (zh "最大")))
    ("speechVolumeMedium"
     ((en "Medium")
      (ja "中")
      (hu "Közepes")
      (fr "Moyen")
      (zh "中")))
    ("speechVolumeMute"
     ((en "Mute")
      (ja "消音")
      (hu "Némítás")
      (fr "Muet")
      (zh "静音")))
    ("unableToPricingMessage"
     ((en "Unable to load product pricing.")
      (ja "商品の価格を読み込めません。")
      (hu "Nem sikerült betölteni a termék árát.")
      (fr "Impossible de charger le prix du produit.")
      (zh "无法加载商品价格。")))
    ("urlCopyRequest"
     ((en "Please copy the link from your browser's address bar."
          ,(make-description "Request message when adding a link."))
      (ja "ブラウザのアドレスバーからリンクをコピーしてください。" )
      (hu "Kérjük, másolja ki a hivatkozást a böngésző címsorából.")
      (fr "Veuillez copier le lien depuis la barre d’adresse de votre navigateur.")
      (zh "请从浏览器地址栏复制链接。")))
    ("urlRequestMessage"
     ((en "Please add a link")
      (ja "リンクを追加してください")
      (hu "Kérjük, adjon meg egy hivatkozást")
      (fr "Veuillez ajouter un lien")
      (zh "请添加链接")))
    ("viewPlainTextDescription"
     ((en "View the current page as plain text."
          ,(make-description "Description of view plain text button."))
      (ja "現在のページをプレーンテキストで表示します。")
      (hu "Az aktuális oldal megjelenítése egyszerű szövegként.")
      (fr "Afficher la page actuelle en texte brut.")
      (zh "以纯文本形式查看当前页面。")))
    ("viewPlainTextLabel"
     ((en "View as plain text")
      (ja "プレーンテキストで表示")
      (hu "Megjelenítés egyszerű szövegként")
      (fr "Afficher en texte brut")
      (zh "以纯文本查看")))
    ("wholeWordsLabel"
     ((en "Whole")
      (ja "全体")
      (hu "Teljes")
      (fr "Entier")
      (zh "全部")))
    ("wordCount"
     ((en "{count, plural, zero {no words} one {1 word} other {{count} words}}"
          ,(make-description "Formated text for word count.")
          ,(make-variables
            (set-variable "count" #:type "int")))
      (ja "{count}単語")
      (hu "{count} szó")
      (fr "{count, plural, zero {aucun mot} one {1 mot} other {{count} mots}}")
      (zh "{count, plural, zero {没有单词} one {1 个单词} other {{count} 个单词}}")))
    ("wordsEncounteredLabel"
     ((en "Words Encountered")
      (ja "出現単語")
      (hu "Előforduló szavak")
      (fr "Mots rencontrés")
      (zh "遇到的单词")))
    ("dateFormatForDailyChart"
     ((en "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))
      (ja "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))
      (hu "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))
      (fr "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "MMMMEEEEd")))
      (zh "{date}"
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
            (set-variable "date2" #:type "DateTime" #:format "yMMMMd")))
      (fr "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "yMMMMd")
            (set-variable "date2" #:type "DateTime" #:format "yMMMMd")))
      (zh "{date1} − {date2}"
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
            (set-variable "date2" #:type "DateTime" #:format "d." #:isCustomDateFormat #t)))
      (fr "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "d")
            (set-variable "date2" #:type "DateTime" #:format "MMMMd")))
      (zh "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "M月d" #:isCustomDateFormat #t)
            (set-variable "date2" #:type "DateTime" #:format "d" #:isCustomDateFormat #t)))))
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
            (set-variable "date2" #:type "DateTime" #:format "MMMMd")))
      (fr "{date1} − {date2}"
          ,(make-variables
            (set-variable "date1" #:type "DateTime" #:format "MMMMd")
            (set-variable "date2" #:type "DateTime" #:format "MMMMd")))
      (zh "{date1} − {date2}"
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
            (set-variable "date" #:type "DateTime" #:format "yMMMM")))
      (fr "{date}"
          ,(make-variables
            (set-variable "date" #:type "DateTime" #:format "yMMMM")))
      (zh "{date}"
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
