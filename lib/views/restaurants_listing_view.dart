// ignore_for_file: unnecessary_string_interpolations, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/restaurants_viewmodel.dart';

class RestaurantsListingScreen extends StatefulWidget {
  @override
  _RestaurantsListingScreenState createState() => _RestaurantsListingScreenState();
}

class _RestaurantsListingScreenState extends State<RestaurantsListingScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<RestaurantsViewModel>(context, listen: false),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Restaurantes"),
          actions: [
            IconButton(
              icon: Icon(Icons.star, color: Colors.orange),
              tooltip: "Ordenar por rating general",
              onPressed: () {
                setState(() {
                  Provider.of<RestaurantsViewModel>(context, listen: false).sortByGeneralRating();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.trending_up, color: Colors.purple),
              tooltip: "Ordenar por rating semanal",
              onPressed: () {
                setState(() {
                  Provider.of<RestaurantsViewModel>(context, listen: false).sortByWeeklyRating();
                });
              },
            ),
          ],
        ),
        body: Consumer<RestaurantsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (viewModel.restaurants.isEmpty) {
              return Center(child: Text("No hay restaurantes disponibles"));
            }
            return ListView.builder(
              itemCount: viewModel.restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = viewModel.restaurants[index];
                final weeklyRating = viewModel.weeklyRatings[restaurant.name] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                          child: restaurant.image.isNotEmpty
                              ? Image.network(restaurant.image, width: 120, height: 120, fit: BoxFit.cover)
                              : Container(width: 120, height: 120, color: Colors.grey[300]),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(restaurant.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(restaurant.address, style: TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis, maxLines: 1),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text("${restaurant.rating.toStringAsFixed(1)}", style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(width: 10),
                                    Icon(Icons.star, size: 16, color: Colors.purple),
                                    SizedBox(width: 4),
                                    Text("${weeklyRating.toStringAsFixed(1)}", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
