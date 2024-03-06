import 'package:flutter/material.dart';

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get appName;

  String get txtRunTracker;

  String get txtWelcomeMapRunnner;

  String get txtImKateYourCoach;

  String get txtBottomSheetDescription;

  String get txtOk;

  String get txtWhatIsYourGender;

  String get txtGenderDescription;

  String get txtHowMuchDoYouWeight;

  String get txtHowTallAreYou;

  String get txtHeightDescription;

  String get txtMale;

  String get txtFemale;

  String get txtNextStep;

  String get txtKG;

  String get txtLBS;

  String get txtLB;

  String get txtCM;

  String get txtFT;

  String get txtYourWeeklyGoalIsReady;

  String get txtHeartHealth;

  String get txtDistance;

  String get txt150MinBriskWalking;

  String get txtPaceBetween9001500MinKm;

  String get txtOR;

  String get txt75MinRunning;

  String get txtPaceOver900MinKm;

  String get txtYouCanCombineTheseTwoDescription;

  String get txtSetAsMyGoal;

  String get txtKM;

  String get txtUseYourLocation;

  String get txtAllow;

  String get txtLocationDesc1;

  String get txtLocationDesc2;

  String get txtGoFasterSmarter;

  String get txtSettings;

  String get txtTarget;

  String get txtReminder;

  String get txtTargetDesc;

  String get txtDrinkWaterReminder;

  String get txtNotifications;

  String get txtSchedule;

  String get txtStart;

  String get txtEnd;

  String get txtInterval;

  String get txtMessage;

  String get txtPaceMinPer;

  String get txtKCAL;

  String get txtMin;

  String get txtIntensity;

  String get txtStop;

  String get txtResume;

  String get txtPause;

  String get txtWellDone;

  String get txtDuration;

  String get txtShare;

  String get txtNotReally;

  String get txtGood;

  String get txtAreYouSatisfiedWithDescription;

  String get txtLongestDistance;

  String get txtBestPace;

  String get txtLongestDuration;

  String get txtRecentActivities;

  String get txtMore;

  String get txtBestRecords;

  String get txtToday;

  String get txtDrinkWater;

  String get txtMl;

  String get txtWeek;

  String get txtWeeklyAverage;

  String get txtTodayRecords;

  String get txtNextTime;

  String get txtTerrible;

  String get txtBad;

  String get txtOkay;

  String get txtGreat;

  String get txtBestWeCanGet;

  String get txtRate;

  String get txtMyProgress;

  String get txtTotalKM;

  String get txtTotalMile;

  String get txtTotalHours;

  String get txtTotalKCAL;

  String get txtAvgPace;

  String get txtMinMi;

  String get txtMinKm;

  String get txtKcal;

  String get txtMile;

  String get txtSteps;

  String get txtStepsTracker;

  String get txtLast7DaysSteps;

  String get txtReset;

  String get txtEditTarget;

  String get txtTurnoff;

  String get txtEditTargetSteps;

  String get txtEditStepsTargetDesc;

  String get txtCancel;

  String get txtSave;

  String get txtWeeklyStatistics;

  String get txtWeekGoalSetting;

  String get txtModerateIntensity;

  String get txtHighIntensity;

  String get txtMetricAndImperialUnits;

  String get txtFinishTraining;

  String get txtFinish;

  String get txtRestart;

  String get txtGotoSettings;

  String get txtPleaseGivePermissionFromSettings;

  String get txtPleaseGivePermissionForActivity;

  String get txtWeNeedYourLocation;

  String get txtLongPressToUnlock;

  String get txtDelete;

  String get txtDrinkWaterNotiMsg;

  String get txtTimeToHydrate;

  String get txtWeight;

  String get txtLast30Days;

  String get txtAdd;

  String get txtWarningForKg;

  String get txtWarningForLbs;

  String get txtTurnedOff;

  String get txtSaveChanges;

  String get txtAlertForNoLocation;

  String get txtDiscard;

  String get txtTime;

  String get txtDeleteHitory;

  String get txtDeleteConfirmationMessage;

  String get txtReport;

  String get txtAverage;

  String get txtMonth;

  String get txtThisWeek;

  String get txtTotal;

  String get txtPaused;

  String get txtRepeat;

  String get txtRunningReminderMsg;

  String get txtUnitSettings;

  String get txtModerate;

  String get txtLow;

  String get txtHigh;

  String get txtWeekGoal;

  String get txtGeneralSettings;

  String get txtLanguageOptions;

  String get txtFirstDayOfWeek;

  String get txtSupportUs;

  String get txtFeedback;

  String get txtRateUs;

  String get txtPrivacyPolicy;

  String get txtRunningReminder;

  String get txtLast7daysReport;

  String get txtEveryHalfHour;

  String get txtEveryOneHour;

  String get txtEveryOneNHalfHour;

  String get txtEveryTwoHour;

  String get txtEveryTwoNHalfHour;

  String get txtEveryThreeHour;

  String get txtEveryThreeNHalfHour;

  String get txtEveryFourHour;

  String get txtDailyReminder;

  String get txtRatingOnGooglePlay;

  String get txtRunTrackerFeedback;

  String get txtSubmit;

  String get txtFeedbackOrSuggestion;

  String get txtShareMapMsg;

  String get txtWriteSuggestionsHere;

  String get txtNoDataFound;

  String get txtExitMessage;

  String get txtExit;

  String get txtTargetStepsWarning;
}
