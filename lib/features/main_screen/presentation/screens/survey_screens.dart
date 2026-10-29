import 'package:apartment_survey_app/features/main_screen/application/apartment/services/apratment_services.dart';
import 'package:apartment_survey_app/features/main_screen/presentation/widgets/apartment_form.dart';
import 'package:apartment_survey_app/features/main_screen/presentation/widgets/dd_blocks.dart';
import 'package:apartment_survey_app/features/main_screen/presentation/widgets/dd_survey_response_widget.dart';
import 'package:flutter/material.dart';
import 'package:apartment_survey_app/features/main_screen/application/apartment/apartment.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key, this.apartmentServices});

  final ApartmentServices? apartmentServices;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late final ApartmentServices apartmentServices;
  String selectedFilter = "all";
  String selectedBlock = "all";
  late final Stream<List<Apartment>> apartmentsStream;
  @override
  void initState() {
    super.initState();
    apartmentServices = widget.apartmentServices ?? ApartmentServices();
    apartmentsStream = apartmentServices.watchApartments();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Apartment Survey"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            DropDownSurveyResponse(
              selectedFilter: selectedFilter,
              onFilterChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue;
                });
              },
            ),
            DropDownBlocks(
              selectedBlock: selectedBlock,
              onBlockChanged: (newValue) {
                setState(() {
                  selectedBlock = newValue;
                });
              },
            ),
            Expanded(
              child: StreamBuilder(
                stream: apartmentsStream,
                builder: (context, asyncSnapshot) {
                  List<Apartment> filteredApartments;
                  if (asyncSnapshot.hasError == true) {
                    return Center(
                      child: Text("${asyncSnapshot.error}"),
                    );
                  }
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (asyncSnapshot.hasData == false) {
                    return Center(
                      child: Text("No data available."),
                    );
                  }
                  List<Apartment> firestoreApartments = asyncSnapshot.data!;
                  if (firestoreApartments.isEmpty) {
                    return Center(
                      child: Text("No Apartments Yet."),
                    );
                  }
                  if (selectedFilter == "all") {
                    filteredApartments = firestoreApartments;
                  } else {
                    filteredApartments = firestoreApartments.where((apartment) {
                      return apartment.status == selectedFilter;
                    }).toList();
                  }
                  if (selectedBlock != "all") {
                    filteredApartments = filteredApartments.where((
                      apartment,
                    ) {
                      return apartment.block == selectedBlock;
                    }).toList();
                  }

                  return ListView.builder(
                    itemCount: filteredApartments.length,
                    itemBuilder: (context, index) {
                      final Apartment apartment = filteredApartments[index];

                      final String job = apartment.job?.trim() ?? "";
                      final String interests =
                          apartment.interests?.trim() ?? "";

                      String displayStatus = filteredApartments[index].status;
                      Color statusColor = Colors.grey;

                      switch (displayStatus) {
                        case "interested":
                          displayStatus = "Interested";
                          statusColor = Colors.green;
                          break;
                        case "not_interested":
                          displayStatus = "Not Interested";
                          statusColor = Colors.grey;
                          break;
                        case "no_answer":
                          displayStatus = "No Answer";
                          statusColor = Colors.orange;
                          break;
                        default:
                      }
                      return Card(
                        child: ListTile(
                          title: Text(
                            "${filteredApartments[index].block} - ${filteredApartments[index].doorNumber}",
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Survey response
                              Text(
                                displayStatus,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              // Job - displayed only if available
                              if (job.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Job: $job",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              // Interests - displayed only if available
                              if (interests.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Interests: $interests",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit),
                              IconButton(
                                onPressed: () async {
                                  Apartment apartmentToDelete =
                                      filteredApartments[index];

                                  bool? confirmed = await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: Text("Delete Apartment?"),
                                        content: Text(
                                          "Are you sure you wanna Delete this Apartment ${apartmentToDelete.block}-${apartmentToDelete.doorNumber}?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                dialogContext,
                                                false,
                                              );
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                dialogContext,
                                                true,
                                              );
                                            },
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmed == true && mounted) {
                                    try {
                                      await apartmentServices.deleteApartment(
                                        apartmentToDelete,
                                      );
                                    } catch (e) {
                                      if (mounted == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Unable to delete apartment. Please try again.",
                                                ),
                                              ),
                                            );
                                      }
                                    }
                                  }
                                },
                                icon: Icon(Icons.delete_outline),
                              ),
                            ],
                          ),

                          onTap: () async {
                            Apartment selectedApartment =
                                filteredApartments[index];
                            Apartment? updatedApartment =
                                await showModalBottomSheet<Apartment>(
                                  context: context,
                                  showDragHandle: true,
                                  isScrollControlled: true,
                                  builder: (BuildContext sheetContext) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: EdgeInsetsGeometry.all(24),
                                        child: ApartmentForm(
                                          initialApartment: selectedApartment,
                                        ),
                                      ),
                                    );
                                  },
                                );
                            if (updatedApartment != null && mounted) {
                              try {
                                await apartmentServices.updateApartment(
                                  selectedApartment,
                                  updatedApartment,
                                );
                              } catch (e) {
                                if (mounted == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Unable to update apartment. Please try again.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Apartment? savedApartment =
                await showModalBottomSheet<Apartment>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (BuildContext sheetContext) {
                    return SafeArea(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(24),
                        child: ApartmentForm(),
                      ),
                    );
                  },
                );
            if (savedApartment != null && mounted) {
              try {
                await apartmentServices.addApartment(savedApartment);
              } catch (e) {
                if (mounted) {
                  if (e is StateError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "This Apartment alredy exists",
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Unable to save apartment. Please try again.",
                        ),
                      ),
                    );
                  }
                }
              }
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
