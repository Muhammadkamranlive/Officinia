import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/model/form_field_data_new.dart';

import '../constants.dart';

class FormFields {
  static Widget entryFormField({required FormFieldDataNew formFieldData}) {
    return Card(
        shadowColor: kSecondaryColor,
        elevation: 5,
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Icon(
                (formFieldData.fieldClassID.contains("name")) ? Icons.person : null,
                color: kPrimaryColor,
                size: 17,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 15.0, top: 3, bottom: 3),
                    child: Text(
                      formFieldData.fieldPlaceholder.toUpperCase(),
                      style: const TextStyle(
                          color: kPrimaryLightColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 5,
                      bottom: 5,
                      right: 15.0,
                    ),
                    child: TextField(
                      //controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: formFieldData.fieldPlaceholder,
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: const TextStyle(
                            color: kSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      style: const TextStyle(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}