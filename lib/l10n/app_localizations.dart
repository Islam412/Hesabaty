import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Capital & Debt Ledger'**
  String get appName;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @cashBook.
  ///
  /// In en, this message translates to:
  /// **'Cash Book'**
  String get cashBook;

  /// No description provided for @debtBook.
  ///
  /// In en, this message translates to:
  /// **'Debt Book'**
  String get debtBook;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @emptyCashBook.
  ///
  /// In en, this message translates to:
  /// **'Here you can record all your daily expenses and income.'**
  String get emptyCashBook;

  /// No description provided for @emptyDebtBook.
  ///
  /// In en, this message translates to:
  /// **'Here you can record all customer and supplier debts.'**
  String get emptyDebtBook;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the app with merchants'**
  String get shareApp;

  /// No description provided for @myBusinessWallet.
  ///
  /// In en, this message translates to:
  /// **'My Business Wallet'**
  String get myBusinessWallet;

  /// No description provided for @walletDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive your money instantly, securely, from anywhere'**
  String get walletDesc;

  /// No description provided for @paymentServices.
  ///
  /// In en, this message translates to:
  /// **'Electronic Payment Services'**
  String get paymentServices;

  /// No description provided for @paymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Offer bill payments and top-ups for your customers and earn commissions'**
  String get paymentDesc;

  /// No description provided for @businessCard.
  ///
  /// In en, this message translates to:
  /// **'Business Card'**
  String get businessCard;

  /// No description provided for @inventoryStaff.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Staff'**
  String get inventoryStaff;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplier;

  /// No description provided for @importContacts.
  ///
  /// In en, this message translates to:
  /// **'Import customer numbers'**
  String get importContacts;

  /// No description provided for @importContactsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sharing phone numbers with the app lets you add new customers quickly.'**
  String get importContactsDesc;

  /// No description provided for @contactsDenied.
  ///
  /// In en, this message translates to:
  /// **'You have disabled access permission to contacts'**
  String get contactsDenied;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get addTags;

  /// No description provided for @tagsDesc.
  ///
  /// In en, this message translates to:
  /// **'Use custom tags (e.g. VIP, wholesale, region) to group and filter your contacts quickly'**
  String get tagsDesc;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @owedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get owedToMe;

  /// No description provided for @owedByMe.
  ///
  /// In en, this message translates to:
  /// **'Owed by me'**
  String get owedByMe;

  /// No description provided for @given.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get given;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get system;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @voidTx.
  ///
  /// In en, this message translates to:
  /// **'Void transaction'**
  String get voidTx;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hesabaty'**
  String get welcomeTitle;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'A ledger that makes it easy to record and manage debts for customers and suppliers. From any phone, anywhere.'**
  String get onb1Body;

  /// No description provided for @onb2.
  ///
  /// In en, this message translates to:
  /// **'All customer debts and payments in your hand at any time, without a paper ledger.'**
  String get onb2;

  /// No description provided for @onb3.
  ///
  /// In en, this message translates to:
  /// **'A detailed statement for every customer.'**
  String get onb3;

  /// No description provided for @onb4.
  ///
  /// In en, this message translates to:
  /// **'Automatic, free payment reminders via WhatsApp.'**
  String get onb4;

  /// No description provided for @onb5.
  ///
  /// In en, this message translates to:
  /// **'Add a note and a photo of the goods or invoice to every transaction.'**
  String get onb5;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @txSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction completed successfully'**
  String get txSuccess;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get finish;

  /// No description provided for @backupSection.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSection;

  /// No description provided for @autoBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily automatic backup'**
  String get autoBackupLabel;

  /// No description provided for @exportShare.
  ///
  /// In en, this message translates to:
  /// **'Export & share now'**
  String get exportShare;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restore;

  /// No description provided for @lastBackupAt.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackupAt;

  /// No description provided for @noBackup.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get noBackup;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get restoreDone;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhone;

  /// No description provided for @phoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Your phone number lets you securely access your account from any phone, anywhere.'**
  String get phoneDesc;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the secret code you received'**
  String get enterOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to'**
  String get otpSentTo;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @resendWait.
  ///
  /// In en, this message translates to:
  /// **'You can resend the code in'**
  String get resendWait;

  /// No description provided for @resendSeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get resendSeconds;

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendNow;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By tapping continue, you agree that you have read and accepted the'**
  String get termsText;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @otpMessage.
  ///
  /// In en, this message translates to:
  /// **'Your verification code is:'**
  String get otpMessage;

  /// No description provided for @wrongCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code, please try again'**
  String get wrongCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
