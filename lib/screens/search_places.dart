import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:users/Assisstants/request_assistants.dart';
import 'package:users/Widgets/place_prediction_tile.dart';
import 'package:users/global/map_key.dart';
import 'package:users/models/predicated_place.dart';

class SearchPlaceScreen extends ConsumerStatefulWidget {
  const SearchPlaceScreen({super.key});

  @override
  ConsumerState<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends ConsumerState<SearchPlaceScreen> {
  List<PredicatedPlace> placesPredicted = [];
  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length >1) {
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:vn";

      var responseAutoComplete = await RequestAssistants.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoComplete == "Error Occurred, Failed. No Response.") {
        return;
      }

      if (responseAutoComplete["status"] == "OK") {
        var places = responseAutoComplete["predictions"];

        var placeList = (places as List)
            .map((jsonData) => PredicatedPlace.fromJson(jsonData))
            .toList();

        setState(() {
          placesPredicted = placeList;
        });
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
            "Search Places",
            style: TextStyle(color: darkTheme ? Colors.black : Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    spreadRadius: 0.5,
                    blurRadius: 5,
                    offset: Offset(0.7, 0.7), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_sharp,
                          color: darkTheme ? Colors.black : Colors.white,
                        ),

                        SizedBox(width: 18.0),
                        Expanded(child: Padding(padding: EdgeInsets.all(8),
                        child: TextField(
                          onChanged: (value) {
                            findPlaceAutoCompleteSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search here...",
                            fillColor: darkTheme
                                ? Colors.black
                                : Colors.white54,
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 11.0,
                              top: 8.0,
                              bottom: 8.0,
                            )

                          ),
                        ),
                        )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //display the predicted places
            (placesPredicted.length > 0) 
            ? Expanded(
              child: ListView.separated(
                itemCount: placesPredicted.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return PlacePredictionTileDesign(
                    predicatedPlace: placesPredicted[index],
                    ref: ref, // truyền ref xuống
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    height: 0,
                    thickness: 0,
                  );
                },
              )
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
