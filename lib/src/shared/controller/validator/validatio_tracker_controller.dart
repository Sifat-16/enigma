import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:flutter/material.dart';

class ValidationTrackerController extends ChangeNotifier{
  bool isValid = true;
  List<bool> validHeatMap = [];
  generateHeatMap({required int length}){
    validHeatMap = List.generate(length, (index)=>false);
    updateValidation();
  }
  updateHeatMapByIndex({required int index, required bool valid}){
    try{
      validHeatMap[index] = valid;
    }catch(e){
      debug("$e");
    }
    updateValidation();
  }

  updateValidation(){
    try{
      isValid = !validHeatMap.contains(false);
    }catch(e){
      debug("$e");
    }
  }
}