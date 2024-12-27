import 'package:enigma/src/shared/controller/validator/validatio_tracker_controller.dart';
import 'package:enigma/src/shared/data/model/validation_tracker/validation_tracker_model.dart';
import 'package:flutter/material.dart';

class ValidationTracker extends StatefulWidget {
  const ValidationTracker({super.key, this.validTrackers = const [], required this.checkerController, this.validationTrackerController});

  final List<ValidationTrackerModel> validTrackers;
  final TextEditingController checkerController;
  final ValidationTrackerController? validationTrackerController;

  @override
  State<ValidationTracker> createState() => _ValidationTrackerState();
}

class _ValidationTrackerState extends State<ValidationTracker> {

  @override
  void initState() {
    // TODO: implement initState
    if(widget.validationTrackerController!=null){
      widget.validationTrackerController?.generateHeatMap(length: widget.validTrackers.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.validTrackers.length,
      itemBuilder: (context, index) {
        ValidationTrackerModel validationTrackerModel = widget.validTrackers[index];
        bool isValid = validationTrackerModel.regExp.hasMatch(widget.checkerController.text.trim());
        try{
          widget.validationTrackerController?.updateHeatMapByIndex(index: index, valid: isValid);
        }catch(e){

        }
        print("Heatmap ${widget.validationTrackerController?.validHeatMap}");
        return ListTile(
          leading: isValid
              ? const Icon(Icons.check_box, color: Colors.green)
              : const Icon(Icons.check_box_outline_blank),
          title: Text(validationTrackerModel.message),
        );
      },
    );
  }
}
