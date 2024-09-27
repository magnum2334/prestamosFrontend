import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para TextInputFormatter
import 'package:stikev/utils/main_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Icon? prefixIcon; // Icono a la izquierda del campo de texto
  final Icon? suffixIcon; // Icono a la derecha del campo de texto
  final double height; // Altura del campo de texto
  final List<TextInputFormatter>? inputFormatters; // Lista de inputFormatters

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 60, // Valor predeterminado para la altura
    this.inputFormatters, // Añadir inputFormatters como parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Container( // Asegúrate de devolver el Container
      height: height, // Usar la altura proporcionada
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Usar inputFormatters
        textAlign: TextAlign.start,
        style: TextStyle(
          color: const Color(0xFF393939),
          fontSize: screenWidth * 0.045, // Aumentar tamaño de fuente
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: AppStyles.text,
            fontSize: screenWidth * 0.04,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 15), // Ajustar padding interno
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: AppStyles.thirdColor,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: AppStyles.thirdColor,
            ),
          ),
        ),
        onChanged: onChanged ?? (value) {},
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
