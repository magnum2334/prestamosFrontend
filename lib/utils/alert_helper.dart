import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class AlertHelper {
  static void showQuickAlert({
    required BuildContext context,
    required QuickAlertType type,
    title,
    required String text,
    confirmBtnText,
    cancelBtnText,
    confirmBtnColor,
  }) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
      confirmBtnColor: confirmBtnColor,
    );
  }

  static void showSuccessAlert(BuildContext context, String text) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.success,
      text: text,
    );
  }

  static void showErrorAlert(BuildContext context, String text) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: text,
    );
  }

  static void showWarningAlert(BuildContext context, String text) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.warning,
      text: text,
    );
  }

  static void showInfoAlert(BuildContext context, String text) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.info,
      text: text,
    );
  }

  static void showConfirmAlert(BuildContext context, String text,
      String confirmBtnText, String cancelBtnText, Color confirmBtnColor) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.confirm,
      text: text,
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
      confirmBtnColor: confirmBtnColor,
    );
  }

  static void showLoadingAlert(BuildContext context, String text) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.loading,
      title: 'Loading',
      text: text,
    );
  }
}
