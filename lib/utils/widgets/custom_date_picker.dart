import 'package:flutter/material.dart';
import 'package:stikev/utils/main_style.dart';

class DatePickerBox extends StatefulWidget {
  final String labelText;
  final double height;
  final TextEditingController controller;

  const DatePickerBox({
    Key? key,
    required this.labelText,
    required this.controller,
    this.height = 60,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DatePickerBoxState createState() => _DatePickerBoxState();
}

class _DatePickerBoxState extends State<DatePickerBox> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Formato YYYY-MM-DD
      widget.controller.text = pickedDate.toIso8601String().split('T').first;
      setState(() {}); // Actualizar el estado para reflejar el cambio
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.controller.text.isNotEmpty ? widget.controller.text : widget.labelText,
                style: TextStyle(
                  color: const Color(0xFF393939),
                  fontSize: screenWidth * 0.045,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Icon(Icons.calendar_today, color: AppStyles.thirdColor),
            ],
          ),
        ),
      ),
    );
  }
}
