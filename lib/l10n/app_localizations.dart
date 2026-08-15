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
  /// **'Auto backup'**
  String get autoBackup;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
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
  /// **'الإصدار'**
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
  /// **'Phone number'**
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
  /// **'Wrong code'**
  String get wrongCode;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @scheduleReminder.
  ///
  /// In en, this message translates to:
  /// **'Schedule reminder'**
  String get scheduleReminder;

  /// No description provided for @reminderDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder date'**
  String get reminderDate;

  /// No description provided for @reminderMsg.
  ///
  /// In en, this message translates to:
  /// **'Reminder message'**
  String get reminderMsg;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled successfully'**
  String get reminderSaved;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled'**
  String get noReminders;

  /// No description provided for @daysUntil.
  ///
  /// In en, this message translates to:
  /// **'days remaining'**
  String get daysUntil;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @cancelReminder.
  ///
  /// In en, this message translates to:
  /// **'Cancel reminder'**
  String get cancelReminder;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get reportPeriod;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @allDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get allDates;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get lastYear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @sendTransactions.
  ///
  /// In en, this message translates to:
  /// **'Send transactions'**
  String get sendTransactions;

  /// No description provided for @importTransactions.
  ///
  /// In en, this message translates to:
  /// **'Import transactions'**
  String get importTransactions;

  /// No description provided for @transactionsImported.
  ///
  /// In en, this message translates to:
  /// **'Transactions imported successfully'**
  String get transactionsImported;

  /// No description provided for @seeAllTransactions.
  ///
  /// In en, this message translates to:
  /// **'See all transactions:'**
  String get seeAllTransactions;

  /// No description provided for @tapForContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Tap here for contact info'**
  String get tapForContactInfo;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @sendMoney.
  ///
  /// In en, this message translates to:
  /// **'Send money'**
  String get sendMoney;

  /// No description provided for @receiveMoney.
  ///
  /// In en, this message translates to:
  /// **'Receive money'**
  String get receiveMoney;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @linkedCards.
  ///
  /// In en, this message translates to:
  /// **'Linked cards'**
  String get linkedCards;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get cardholderName;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get sendTo;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get selectDestination;

  /// No description provided for @vodafoneCash.
  ///
  /// In en, this message translates to:
  /// **'Vodafone Cash'**
  String get vodafoneCash;

  /// No description provided for @orangeCash.
  ///
  /// In en, this message translates to:
  /// **'Orange Cash'**
  String get orangeCash;

  /// No description provided for @etisalatCash.
  ///
  /// In en, this message translates to:
  /// **'Etisalat Cash'**
  String get etisalatCash;

  /// No description provided for @instapay.
  ///
  /// In en, this message translates to:
  /// **'InstaPay'**
  String get instapay;

  /// No description provided for @meeza.
  ///
  /// In en, this message translates to:
  /// **'Meeza Card'**
  String get meeza;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get bankAccount;

  /// No description provided for @cardOrAccount.
  ///
  /// In en, this message translates to:
  /// **'Card or account number'**
  String get cardOrAccount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @confirmSend.
  ///
  /// In en, this message translates to:
  /// **'Confirm & send'**
  String get confirmSend;

  /// No description provided for @transactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction successful'**
  String get transactionSuccess;

  /// No description provided for @transactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction failed'**
  String get transactionFailed;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get referenceNumber;

  /// No description provided for @walletHistory.
  ///
  /// In en, this message translates to:
  /// **'Wallet history'**
  String get walletHistory;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @toppedUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get toppedUp;

  /// No description provided for @cardAdded.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAdded;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove card'**
  String get removeCard;

  /// No description provided for @defaultCard.
  ///
  /// In en, this message translates to:
  /// **'Default card'**
  String get defaultCard;

  /// No description provided for @fromCard.
  ///
  /// In en, this message translates to:
  /// **'From card'**
  String get fromCard;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get shareReceipt;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank name (optional)'**
  String get bankName;

  /// No description provided for @createPaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Create payment link'**
  String get createPaymentLink;

  /// No description provided for @chooseCustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose customer'**
  String get chooseCustomer;

  /// No description provided for @linkReady.
  ///
  /// In en, this message translates to:
  /// **'Link ready — share it now'**
  String get linkReady;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Islam Elsouly'**
  String get ownerName;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get activity;

  /// No description provided for @cardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved successfully'**
  String get cardSaved;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareAsImage;

  /// No description provided for @shareAsVcard.
  ///
  /// In en, this message translates to:
  /// **'Share as contact'**
  String get shareAsVcard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit business card'**
  String get editCard;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @sendCard.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendCard;

  /// No description provided for @pickBackground.
  ///
  /// In en, this message translates to:
  /// **'Pick background from phone'**
  String get pickBackground;

  /// No description provided for @customDesign.
  ///
  /// In en, this message translates to:
  /// **'My custom design'**
  String get customDesign;

  /// No description provided for @cardDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Card saved to Documents'**
  String get cardDownloaded;

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Swipe to choose card style'**
  String get chooseTemplate;

  /// No description provided for @supportWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp support'**
  String get supportWhatsApp;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get supportEmail;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get callSupport;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @cantOpen.
  ///
  /// In en, this message translates to:
  /// **'Cannot open link'**
  String get cantOpen;

  /// No description provided for @appOwner.
  ///
  /// In en, this message translates to:
  /// **'App owner'**
  String get appOwner;

  /// No description provided for @devCompany.
  ///
  /// In en, this message translates to:
  /// **'Development company'**
  String get devCompany;

  /// No description provided for @appEngineer.
  ///
  /// In en, this message translates to:
  /// **'App engineer'**
  String get appEngineer;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get openMap;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @backupSettings.
  ///
  /// In en, this message translates to:
  /// **'Backup settings'**
  String get backupSettings;

  /// No description provided for @autoBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup data automatically on schedule'**
  String get autoBackupDesc;

  /// No description provided for @backupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Backup frequency'**
  String get backupFrequency;

  /// No description provided for @backupTime.
  ///
  /// In en, this message translates to:
  /// **'Backup time'**
  String get backupTime;

  /// No description provided for @deleteOldBackups.
  ///
  /// In en, this message translates to:
  /// **'Delete old backups'**
  String get deleteOldBackups;

  /// No description provided for @deleteOldBackupsDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep only the latest 5 backups'**
  String get deleteOldBackupsDesc;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get hourly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @customDay.
  ///
  /// In en, this message translates to:
  /// **'Custom day'**
  String get customDay;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select day'**
  String get selectDay;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup now'**
  String get backupNow;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreated;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupRestored;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm restore? Current data will be replaced.'**
  String get confirmRestore;

  /// No description provided for @noBackups.
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get noBackups;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackup;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @backupLocation.
  ///
  /// In en, this message translates to:
  /// **'Backup location'**
  String get backupLocation;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder in file manager'**
  String get openFolder;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @backupScheduled.
  ///
  /// In en, this message translates to:
  /// **'Next backup scheduled'**
  String get backupScheduled;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU/Code'**
  String get sku;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @minStock.
  ///
  /// In en, this message translates to:
  /// **'Min stock'**
  String get minStock;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add stock'**
  String get addStock;

  /// No description provided for @removeStock.
  ///
  /// In en, this message translates to:
  /// **'Remove stock'**
  String get removeStock;

  /// No description provided for @stockMovement.
  ///
  /// In en, this message translates to:
  /// **'Stock movement'**
  String get stockMovement;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployee;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get editEmployee;

  /// No description provided for @employeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee name'**
  String get employeeName;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Job role'**
  String get role;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @salaryType.
  ///
  /// In en, this message translates to:
  /// **'Salary type'**
  String get salaryType;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join date'**
  String get joinDate;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @paySalary.
  ///
  /// In en, this message translates to:
  /// **'Pay salary'**
  String get paySalary;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get totalProducts;

  /// No description provided for @totalStockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get totalStockValue;

  /// No description provided for @totalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total employees'**
  String get totalEmployees;

  /// No description provided for @monthlySalaries.
  ///
  /// In en, this message translates to:
  /// **'Monthly salaries'**
  String get monthlySalaries;

  /// No description provided for @piece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get piece;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @box.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get box;

  /// No description provided for @pack.
  ///
  /// In en, this message translates to:
  /// **'pack'**
  String get pack;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'تطبيق إدارة الحسابات والمخزون والموظفين الشامل'**
  String get aboutDesc;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'المطور'**
  String get developer;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'م. إسلام حمدي'**
  String get developerName;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'م. إسلام حمدي'**
  String get company;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'تليجرام'**
  String get telegram;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'المشروع على GitHub'**
  String get github;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'جميع الحقوق محفوظة'**
  String get copyright;

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// No description provided for @totalUsed.
  ///
  /// In en, this message translates to:
  /// **'Total used space'**
  String get totalUsed;

  /// No description provided for @customPath.
  ///
  /// In en, this message translates to:
  /// **'Custom location'**
  String get customPath;

  /// No description provided for @defaultPath.
  ///
  /// In en, this message translates to:
  /// **'Default location'**
  String get defaultPath;

  /// No description provided for @dbLabel.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get dbLabel;

  /// No description provided for @backupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get backupsLabel;

  /// No description provided for @currentPath.
  ///
  /// In en, this message translates to:
  /// **'Current storage location'**
  String get currentPath;

  /// No description provided for @changePath.
  ///
  /// In en, this message translates to:
  /// **'Change storage location'**
  String get changePath;

  /// No description provided for @resetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default location'**
  String get resetDefault;

  /// No description provided for @transferring.
  ///
  /// In en, this message translates to:
  /// **'Transferring data...'**
  String get transferring;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export as image'**
  String get exportTitle;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get saveImage;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareImage;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get lockTitle;

  /// No description provided for @protectTitle.
  ///
  /// In en, this message translates to:
  /// **'App Protection'**
  String get protectTitle;

  /// No description provided for @chooseLock.
  ///
  /// In en, this message translates to:
  /// **'Choose the unlock method that suits you'**
  String get chooseLock;

  /// No description provided for @unlockMethod.
  ///
  /// In en, this message translates to:
  /// **'Unlock method'**
  String get unlockMethod;

  /// No description provided for @noLock.
  ///
  /// In en, this message translates to:
  /// **'No lock'**
  String get noLock;

  /// No description provided for @bioLock.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint / Face'**
  String get bioLock;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinLock;

  /// No description provided for @digits46.
  ///
  /// In en, this message translates to:
  /// **'4-6 digits'**
  String get digits46;

  /// No description provided for @passLock.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passLock;

  /// No description provided for @patternLock.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get patternLock;

  /// No description provided for @bioAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available on your device'**
  String get bioAvailable;

  /// No description provided for @bioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get bioUnavailable;

  /// No description provided for @bioSection.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get bioSection;

  /// No description provided for @faceOpen.
  ///
  /// In en, this message translates to:
  /// **'Open with face'**
  String get faceOpen;

  /// No description provided for @fingerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open with fingerprint'**
  String get fingerOpen;

  /// No description provided for @bioExtra.
  ///
  /// In en, this message translates to:
  /// **'As an addition to the main method'**
  String get bioExtra;

  /// No description provided for @lockedTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get lockedTitle;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @enterPass.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPass;

  /// No description provided for @drawPattern.
  ///
  /// In en, this message translates to:
  /// **'Draw the pattern'**
  String get drawPattern;

  /// No description provided for @openBtn.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openBtn;

  /// No description provided for @touchBio.
  ///
  /// In en, this message translates to:
  /// **'Touch to unlock'**
  String get touchBio;

  /// No description provided for @bioOrFace.
  ///
  /// In en, this message translates to:
  /// **'Open with fingerprint / face'**
  String get bioOrFace;

  /// No description provided for @wrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Verification failed — try again'**
  String get wrongTryAgain;

  /// No description provided for @cvvInvalid.
  ///
  /// In en, this message translates to:
  /// **'CVV is invalid (3-4 digits)'**
  String get cvvInvalid;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Card number is invalid — check the digits'**
  String get cardNumberInvalid;

  /// No description provided for @cardHolderRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the card holder name'**
  String get cardHolderRequired;

  /// No description provided for @expiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Expiry must be MM/YY and in the future'**
  String get expiryInvalid;

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay bill'**
  String get payBill;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get openInMaps;

  /// No description provided for @billsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill Payments & Top-ups'**
  String get billsTitle;

  /// No description provided for @mobileTopup.
  ///
  /// In en, this message translates to:
  /// **'Mobile top-up'**
  String get mobileTopup;

  /// No description provided for @internet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get internet;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @gas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get gas;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @landline.
  ///
  /// In en, this message translates to:
  /// **'Landline'**
  String get landline;

  /// No description provided for @tv.
  ///
  /// In en, this message translates to:
  /// **'Television'**
  String get tv;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get donations;

  /// No description provided for @govServices.
  ///
  /// In en, this message translates to:
  /// **'Government services'**
  String get govServices;

  /// No description provided for @servicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'services available'**
  String get servicesAvailable;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'unread'**
  String get unread;

  /// No description provided for @appDeveloper.
  ///
  /// In en, this message translates to:
  /// **'App developer'**
  String get appDeveloper;

  /// No description provided for @aboutFeatures.
  ///
  /// In en, this message translates to:
  /// **'App features'**
  String get aboutFeatures;

  /// No description provided for @ownerSection.
  ///
  /// In en, this message translates to:
  /// **'App owner'**
  String get ownerSection;

  /// No description provided for @devSection.
  ///
  /// In en, this message translates to:
  /// **'App developer'**
  String get devSection;

  /// No description provided for @contactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact the owner'**
  String get contactOwner;

  /// No description provided for @emailBtn.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailBtn;

  /// No description provided for @telegramBtn.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegramBtn;

  /// No description provided for @websiteBtn.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteBtn;

  /// No description provided for @rights.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get rights;

  /// No description provided for @shareAppMerchants.
  ///
  /// In en, this message translates to:
  /// **'Share the app with merchants'**
  String get shareAppMerchants;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @ownerRole.
  ///
  /// In en, this message translates to:
  /// **'App owner & developer'**
  String get ownerRole;

  /// No description provided for @featCash.
  ///
  /// In en, this message translates to:
  /// **'Cash Book'**
  String get featCash;

  /// No description provided for @featDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt Book'**
  String get featDebt;

  /// No description provided for @featWallet.
  ///
  /// In en, this message translates to:
  /// **'Commercial Wallet'**
  String get featWallet;

  /// No description provided for @featBills.
  ///
  /// In en, this message translates to:
  /// **'E-Payment Services'**
  String get featBills;

  /// No description provided for @featInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get featInventory;

  /// No description provided for @featStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get featStaff;

  /// No description provided for @featNotif.
  ///
  /// In en, this message translates to:
  /// **'Instant Notifications'**
  String get featNotif;

  /// No description provided for @featBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get featBackup;

  /// No description provided for @featLock.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Lock'**
  String get featLock;

  /// No description provided for @featCard.
  ///
  /// In en, this message translates to:
  /// **'Digital Business Card'**
  String get featCard;

  /// No description provided for @featPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF Statements'**
  String get featPdf;

  /// No description provided for @featAccounts.
  ///
  /// In en, this message translates to:
  /// **'Multiple Accounts'**
  String get featAccounts;

  /// No description provided for @featDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get featDark;

  /// No description provided for @featLang.
  ///
  /// In en, this message translates to:
  /// **'Arabic / English'**
  String get featLang;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Cash book, debts & wallet in one app'**
  String get appTagline;

  /// No description provided for @devBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get devBy;

  /// No description provided for @faq1q.
  ///
  /// In en, this message translates to:
  /// **'Is my data safe?'**
  String get faq1q;

  /// No description provided for @faq1a.
  ///
  /// In en, this message translates to:
  /// **'Yes ✅ All your data is stored only on your device in an encrypted database, nothing is shared.'**
  String get faq1a;

  /// No description provided for @faq2q.
  ///
  /// In en, this message translates to:
  /// **'How do I make a backup?'**
  String get faq2q;

  /// No description provided for @faq2a.
  ///
  /// In en, this message translates to:
  /// **'Settings → Backup settings → Create backup. Auto backup is also available.'**
  String get faq2a;

  /// No description provided for @faq3q.
  ///
  /// In en, this message translates to:
  /// **'How do I share a statement with a client?'**
  String get faq3q;

  /// No description provided for @faq3a.
  ///
  /// In en, this message translates to:
  /// **'Open the client → share button sends the statement image + a link with all transactions.'**
  String get faq3a;

  /// No description provided for @faq4q.
  ///
  /// In en, this message translates to:
  /// **'How do I pay bills from the app?'**
  String get faq4q;

  /// No description provided for @faq4a.
  ///
  /// In en, this message translates to:
  /// **'More → Electronic Payment Services → choose the bill type and pay.'**
  String get faq4a;

  /// No description provided for @devName.
  ///
  /// In en, this message translates to:
  /// **'Eng. Islam Hamdy'**
  String get devName;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;
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
