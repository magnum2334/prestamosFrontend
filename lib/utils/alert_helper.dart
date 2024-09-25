import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class AlertHelper {
  static void showQuickAlert({
    required BuildContext context,
    required QuickAlertType type,
    String? title, // Permitimos que title sea nulo
    required String text,
    String? confirmBtnText, // Permitimos que confirmBtnText sea nulo
    String? cancelBtnText, // Permitimos que cancelBtnText sea nulo
    Color? confirmBtnColor, // Permitimos que confirmBtnColor sea nulo
  }) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText ?? 'OK', // Valor predeterminado si es nulo
      cancelBtnText: cancelBtnText ?? 'Cancelar',
      confirmBtnColor:
          confirmBtnColor ?? Colors.blue, // Valor predeterminado si es nulo
    );
  }

  static void showSuccessAlert(BuildContext context, String text) {
    showQuickAlert(
      context: context,
      type: QuickAlertType.success,
      text: text,
    );
  }

  static void showErrorAlert(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: message,
      confirmBtnText: 'OK',
      confirmBtnColor: Colors.red,
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
      {required String confirmBtnText,
      required String cancelBtnText,
      required Color confirmBtnColor}) {
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
