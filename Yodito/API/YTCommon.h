
//#define kYTIsBeta // !!! Comment this line before upload to itunes !!!

#define kYTDebugMode NO//YES // If YES, app performs some debug actions - write log, show alerts etc. Should be NO before submitting to app store.

#define kYTShowTestButtons (kYTDebugMode && NO)
//#define kYTDebugNoUploadWhenSync NO//YES//NO

#define kYTAppName @"All.Notes"

#define kYTUrlWebServerHostName @"www.allnotes.co"
#define kYTUrlWebServer [NSString stringWithFormat:@"https://%@", kYTUrlWebServerHostName]
#define kYTUrlApi [NSString stringWithFormat:@"%@/%@", kYTUrlWebServer, @"api/yoditoAPI.php"]

#define kYTAppId (kYTDebugMode ? @"285217489" : @"829613138")

#define kYTTestFlightAppToken @"ae8015f4-cf64-46d8-a059-b435f81462b5"

#define kYTFullSyncEventIfTimeStampsEqual YES//NO
#define kYTShowSyncOnWiFiOnlyOption YES//NO
#define kYTAllowSyncInBackground YES//NO
#define kYTSyncDownloadAndStoreAllPhotos YES//NO
#define kYTUseSyncChunksApi YES//NO
#define kYTDisableUploadChangesToServer NO//YES//NO
#define kYTAutoSaveEditedNote YES//NO
#define kYTAddDeleteEventsFromAppToIPhone NO//YES
#define kYTUpdateEventsFromAppToIPhone NO//YES
#define kYTShowSupportContactButton YES//NO
#define kYTAllowSignOut NO//YES
#define kYTAllowOpenNonImageResources YES//NO//YES
#define kYTImagesCacheMaxSizeInBytes (25 * 1024 * 1024)
#define kYTAutoSyncWhenActivatedDelay 12.5
#define kYTAutoSyncWhenDataChangedDelay 7.0
#define kYTAutoSyncMinInterval 10.0
#define kYTAutoSyncOnlyAppActivatedFirstTime YES//NO
#define kYTStopSyncSubentitiesIfErrorReceived NO//YES
#define kYTUseServerTimeAsLastSyncTime NO//YES
#define kYTUseChunkHighTSAsLastSyncTime NO//YES

#define kYTDefaultJpegImageQuality 0.96
#define kYTImageCachMaxAllPixelsAmount (1024 * 1024 * 2)

#define kYTMinPackageNumberForPremium 2
#define kYTGetSyncChunkNotesPerPage 20//10

#define kYTLoggingEnabled YES//NO
#define kYTLogToFile (kYTDebugMode || YES)
#define kYTMaxLogFileSizes (1000*1024)
#define kYTMaxCharsInLogItem (10*1024)
#define kYTMaxImagesDownloadingAtOnce 4

//#define kYTPhotoThumbnailSize CGSizeMake(145*2, 100*2)
//#define kYTPhotoThumbnailSize CGSizeMake(290*2, 200*2)
#define kYTPhotoThumbnailSize CGSizeMake(290*3, 200*3)
#define kYTPhotoPreviewMaxWidth ([VLDeviceManager isMacDevice] ? 1280.0 : 640.0)
#define kYTPhotoMiniPreviewMaxSide ([VLDeviceManager isMacDevice] ? 256.0 : 128.0)//64.0

#define kYTResourceDownloadWaitingForReloadEnabled YES//NO
#define kYTResourceDownloadWaitingForReloadMaxTime 60.0//10.0
#define kYTResourceDownloadWaitingForReloadObscureWaiting YES//NO
#define kYTAllowDeleteResource NO//YES
#define kYTMoveDoneRemindersToAllNotes NO//YES//NO
#define kYTAllowEditTag NO//YES
#define kYTMinimumBackgroundFetchInterval (kYTDebugMode ? 30.0 : 3600.0)
#define kYTAllowDeleteNotebook NO//YES

#define kYTCurrentAppVersionKey @"kYTCurrentAppVersionKey"
#define kYTCurrentAppBuildKey @"kYTCurrentAppBuildKey"

#define kYTUrlParamOperation @"operation"
#define kYTUrlValueOperationAuthenticate @"authenticate"
#define kYTUrlValueOperationRefreshAuthentication @"RefreshAuthentication"
#define kYTUrlValueOperationLogout @"Logout"
#define kYTUrlValueOperationGetUser @"GetUser"
#define kYTUrlValueOperationRegisterUser @"RegisterUser"
#define kYTUrlValueOperationFirstLogin @"FirstLogin"
#define kYTUrlValueOperationForgotPassword @"forgotpassword"
#define kYTUrlValueOperationListStacks @"ListStacks"
#define kYTUrlValueOperationGetStack @"GetStack"
#define kYTUrlValueOperationDeleteStack @"DeleteStack"
#define kYTUrlValueOperationCreateStack @"CreateStack"
#define kYTUrlValueOperationUpdateStack @"UpdateStack"
#define kYTUrlValueOperationListNotebooks @"ListNotebooks"
#define kYTUrlValueOperationDeleteNotebook @"DeleteNotebook"
#define kYTUrlValueOperationCreateNotebook @"CreateNotebook"
#define kYTUrlValueOperationUpdateNotebook @"UpdateNotebook"
#define kYTUrlValueOperationGetNotebook @"GetNotebook"
#define kYTUrlValueOperationListNotes @"ListNotes"
#define kYTUrlValueOperationDeleteNote @"DeleteNote"
#define kYTUrlValueOperationCreateNote @"CreateNote"
#define kYTUrlValueOperationUpdateNote @"UpdateNote"
#define kYTUrlValueOperationUpdateNoteFromiPhone @"UpdateNoteFromiPhone"
#define kYTUrlValueOperationUpdateNoteFromiPhone2 @"UpdateNoteFromiPhone2"
#define kYTUrlValueOperationGetNote @"GetNote"
#define kYTUrlValueOperationGetResources @"GetResources"
#define kYTUrlValueOperationSetResource @"setresource"
#define kYTUrlValueOperationGetResourceData @"GetResourceData"
#define kYTUrlValueOperationDeleteResource @"DeleteResource"
#define kYTUrlValueOperationListTags @"ListTags"
#define kYTUrlValueOperationDeleteTag @"DeleteTag"
#define kYTUrlValueOperationCreateTag @"CreateTag"
#define kYTUrlValueOperationUpdateTag @"updatetag"
#define kYTUrlValueOperationListLocations @"ListLocations"
#define kYTUrlValueOperationDeleteLocation @"DeleteLocation"
#define kYTUrlValueOperationCreateLocation @"CreateLocation"
#define kYTUrlValueOperationUpdateLocation @"UpdateLocation"
#define kYTUrlValueOperationDeleteChecklist @"DeleteChecklist"
#define kYTUrlValueOperationListChecklists @"ListChecklists"
#define kYTUrlValueOperationUpdateChecklist @"UpdateChecklist"
#define kYTUrlValueOperationCreateChecklists @"CreateChecklists"
#define kYTUrlValueOperationListReminders @"ListReminders"
#define kYTUrlValueOperationDeleteReminder @"DeleteReminder"
#define kYTUrlValueOperationCreateReminder @"CreateReminder"
#define kYTUrlValueOperationUpdateReminder @"UpdateReminder"
#define kYTUrlValueOperationGetRecurrence @"GetRecurrence"
#define kYTUrlValueOperationDeleteRecurrence @"DeleteRecurrence"
#define kYTUrlValueOperationCreateRecurrence @"CreateRecurrence"
#define kYTUrlValueOperationUpdateRecurrence @"UpdateRecurrence"
#define kYTUrlValueOperationGetSyncState @"GetSyncState"
#define kYTUrlValueOperationGetSyncChunk @"GetSyncChunk"
#define kYTUrlValueOperationGetSyncChunk2 @"GetSyncChunk2"
#define kYTUrlValueOperationGetSyncChunk3 @"GetSyncChunk3"
#define kYTUrlValueOperationAcceptPayment @"acceptpayment"

#define kYTDefaultWebTimeout (60.0 * 3)
#define kYTDefaultWebTimeoutBigData (60.0 * 4)
#define kYTDefaultWebTimeoutShort (30.0)
#define kYTRefreshAuthenticateInterval 86400.0

#define kYTJsonKeyId @"Id"
#define kYTJsonKeyAuthenticationToken @"authenticationToken"
#define kYTJsonKeyCurrentTime @"currentTime"
#define kYTJsonKeyExpiration @"expiration"
#define kYTJsonKeyUser @"user"
#define kYTJsonKeyAccountStatus @"AccountStatus"
#define kYTJsonKeyCreatedDate @"CreatedDate"
#define kYTJsonKeyDiskSpaceUsed @"DiskSpaceUsed"
#define kYTJsonKeyEmailId1 @"EmailId1"
#define kYTJsonKeyEmailId2 @"EmailId2"
#define kYTJsonKeyEmailId3 @"EmailId3"
#define kYTJsonKeyFirstName @"FirstName"
#define kYTJsonKeyLastName @"LastName"
#define kYTJsonKeyLastUpdateTS @"LastUpdateTS"
#define kYTJsonKeyPackageId @"PackageId"
#define kYTJsonKeyIsDemo @"IsDemo"
#define kYTJsonKeyHasDemoData @"HasDemoData"
#define kYTJsonKeyPersonId @"PersonId"
#define kYTJsonKeyStatus @"Status"
#define kYTJsonKeyStackId @"StackId"
#define kYTJsonKeyStackName @"StackName"
#define kYTJsonKeyIsValid @"IsValid"
#define kYTJsonKeyColorId @"ColourId"
#define kYTJsonKeyName @"Name"
#define kYTJsonKeyNoteGUID @"NoteGUID"
#define kYTJsonKeyNotebookId @"NotebookId"
#define kYTJsonKeyNotebookGUID @"NotebookGUID"
#define kYTJsonKeynotebookGuid @"notebookGuid"
#define kYTJsonKeyPriorityId @"PriorityId"
#define kYTJsonKeyCreatedAt @"CreatedAt"
#define kYTJsonKeyTitle @"Title"
#define kYTJsonKeyContent @"Content"
#define kYTJsonKeyContentLimited @"ContentLimited"
#define kYTJsonKeyContentToUpdateFromIPhone @"ContentToUpdateFromIPhone"
#define kYTJsonKeyCharacters @"Characters"
#define kYTJsonKeyWords @"Words"
#define kYTJsonKeyCreatedDate @"CreatedDate"
#define kYTJsonKeyDueDate @"DueDate"
#define kYTJsonKeyEndDate @"EndDate"
#define kYTJsonKeyIsCheckList @"IsCheckList"
#define kYTJsonKeyHasAttachment @"HasAttachment"
#define kYTJsonKeyHasReminder @"HasReminder"
#define kYTJsonKeyHasTag @"HasTag"
#define kYTJsonKeyHasURL @"HasURL"
#define kYTJsonKeyHasRelatedNotes @"HasRelatedNotes"
#define kYTJsonKeyHasLocation @"HasLocation"
#define kYTJsonKeyRecurrenceid @"Recurrenceid"
#define kYTJsonKeyAttachmentId @"AttachmentId"
#define kYTJsonKeyAttachmentCategoryId @"AttachmentCategoryId"
#define kYTJsonKeyAttachmentTypeName @"AttachmentTypeName"
#define kYTJsonKeyResourceId @"ResourceId"
#define kYTJsonKeyS3StorageUUID @"S3StorageUUID"
#define kYTJsonKeyFilename @"Filename"
#define kYTJsonKeyDescription @"Description"
#define kYTJsonKeyIsThumbnail @"IsThumbnail"
#define kYTJsonKeyParentAttachmentId @"ParentAttachmentId"
#define kYTJsonKeyAttachmenthash @"Attachmenthash"
#define kYTJsonKeyTagId @"TagId"
#define kYTJsonKeyLocationId @"LocationId"
#define kYTJsonKeyLatitude @"Latitude"
#define kYTJsonKeyLongitude @"Longitude"
#define kYTJsonKeyNo @"No"
#define kYTJsonKeyIsDone @"IsDone"
#define kYTJsonKeyReminderId @"ReminderId"
#define kYTJsonKeyWhatToDo @"WhatToDo"
#define kYTJsonKeyAlertDatetime @"AlertDatetime"
#define kYTJsonKeyAlertType @"AlertType"
#define kYTJsonKeyRepeatPeriod @"RepeatPeriod"
#define kYTJsonKeyRepeatTimeUnit @"RepeatTimeUnit"
#define kYTJsonKeyAuthor @"Author"
#define kYTJsonKeyFavicon @"Favicon"
#define kYTJsonKeyStartTime @"StartTime"
#define kYTJsonKeyEndTime @"EndTime"
#define kYTJsonKeyDay @"Day"
#define kYTJsonKeyWeekday @"Weekday"
#define kYTJsonKeyMonth @"Month"
#define kYTJsonKeyWeekNumber @"WeekNumber"
#define kYTJsonKeyStartDate @"StartDate"
#define kYTJsonKeyNumOccurences @"NumOccurences"
#define kYTJsonKeyIsTemporary @"IsTemporary"
#define kYTJsonKeyIsLocal @"IsLocal"
#define kYTJsonKeycurrentTime @"currentTime"
#define kYTJsonKeychunkHighTS @"chunkHighTS"
#define kYTJsonKeyuploaded @"uploaded"
#define kYTJsonKeyNoteChanges @"NoteChanges"
#define kYTJsonKeyCheckList @"CheckList"
#define kYTJsonKeyAttachment @"Attachment"
#define kYTJsonKeyReminder @"Reminder"
#define kYTJsonKeyTag @"Tag"
#define kYTJsonKeyURL @"URL"
#define kYTJsonKeyRelation @"Relation"
#define kYTJsonKeyLocation @"Location"
#define kYTJsonKeyResultCode @"result_code"
#define kYTJsonKeyTransactionDate @"TransactionDate"
#define kYTJsonKeyAmount @"Amount"
#define kYTJsonKeyTransactionId @"TransactionId"
#define kYTJsonKeyRepeat @"Repeat"
#define kYTJsonKeyVisibility @"Visibility"
#define kYTJsonKeyIsDefault @"IsDefault"
#define kYTJsonKeyCurrentPage @"CurrentPage"
#define kYTJsonKeyTotalNotes @"TotalNotes"
#define kYTJsonKeyEntity @"Entity"
#define kYTJsonKeyEntityID @"EntityID"
#define kYTJsonKeyNoteID @"NoteID"
#define kYTJsonKeyTagsIds @"tagsIds"

#define kYTManagersBaseVersion 69

#define kYTDatabaseFileName @"allnotes.sqlite"
#define kYTDatabaseVersion (kYTManagersBaseVersion + 49)

#define kYTDbTableUser @"t_user"
#define kYTDbTableStack @"t_stack"
#define kYTDbTableNotebook @"t_notebook"
#define kYTDbTableNote @"t_note"
#define kYTDbTableNoteContent @"t_note_content"
#define kYTDbTableNoteToTag @"t_note_to_tag"
#define kYTDbTableNoteToLocation @"t_note_to_location"
#define kYTDbTableNoteToResource @"t_note_to_resource"
#define kYTDbTableResource @"t_resource"
#define kYTDbTableTag @"t_tag"
#define kYTDbTableLocation @"t_location"

#define kYTCreateResourceImageThumbnails YES//NO
#define kYTResourceThumbnailFileExt @"jpg"
#define kYTResourceImageFileExt @"jpg"//@"png"
//#define kYTResourceThumbnailMaxSide 100
#define kYTResourceAudioFileExt @"m4a"//@"caf"
#define kYTResourceAudioTempFileName @"tempaudio"
#define kYTResourceVideoTempFileName @"tempvideo"
#define kYTResourceCanPickVideo NO//YES

#define kYTNoteContentLimitedLimit 200

#define kYTMaxSimulRequestsAdding 2
#define kYTMaxSimulRequestsDeleting 999
#define kYTMaxSimulRequestsModifying 2
#define kYTMaxSimulRequestsListing 2

#define kYTAllowNotLoggenInUser YES//NO

#define kYTMessageCenterTimerInterval 0.2
#define kYTTimerIntervalMultiplier 1.0











