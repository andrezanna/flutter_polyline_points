class Step{
  late String instruction;
  late String travelMode;
  late Map<String,dynamic> details;

  Step.fromJSON(Map<String,dynamic> jsonMap){
    try {
      instruction = jsonMap["html_instructions"];
      travelMode = jsonMap["travel_mode"];
      details = jsonMap["transit_details"];
    }catch(e,stack){
      print(e);
      print(stack);
    }
  }
}