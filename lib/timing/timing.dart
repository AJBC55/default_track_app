import 'package:flutter/material.dart';
import 'timing_msgs.dart';
import 'racer_info.dart';
import 'package:provider/provider.dart';
import 'timing_provider.dart';

class TimingScreen extends StatefulWidget {
  @override
  _TimingScreenState createState() => _TimingScreenState();
}

class _TimingScreenState extends State<TimingScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timingProvider = Provider.of<TimingSessionProvider>(context, listen: false);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      print("App is paused/inactive");
      timingProvider.stopStreaming();
    } else if (state == AppLifecycleState.resumed) {
      print("App is resumed");
      timingProvider.startStreaming();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timingProvider = context.watch<TimingSessionProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135.0),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 198, 198, 198),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Race: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '${timingProvider.session.run.description}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Class: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '${timingProvider.session.classData.description}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Laps To Go: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '${timingProvider.session.raceStatus.lapsToGo}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 28.0,
                        height: 28.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _buildStatusColorCell(
                            timingProvider.session.raceStatus.flagStatus,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: timingProvider.toggleByRacePos,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black, width: 3.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          timingProvider.byRacePos
                              ? 'Sort by Time'
                              : 'Sort by Race Pos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: timingProvider.session.racers.isEmpty
            ? Center(
                child: Text(
                  'Timing not available.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : _buildRacersList(timingProvider.session.racers),
      ),
    );
  }

  Color _buildStatusColorCell(String flagStatus) {
    switch (flagStatus.toLowerCase()) {
      case 'green':
        return const Color.fromARGB(255, 13, 96, 16);
      case 'yellow':
        return const Color.fromARGB(255, 220, 204, 64);
      case 'red':
        return const Color.fromARGB(255, 143, 33, 25);
      case 'white':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRacersList(List<RacerInfo> racers) {
    List<Time> nonZeroLapTimes = racers
        .map((racer) => racer.pqPosition.bestLapTime)
        .where((lapTime) => lapTime.toDouble() > 0.0)
        .toList();

    Time bestLapTime;
    if (nonZeroLapTimes.isNotEmpty) {
      bestLapTime = nonZeroLapTimes.reduce((a, b) => a.lessThan(b) ? a : b);
    } else {
      bestLapTime = Time();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color.fromARGB(255, 4, 59, 107),
            
          ),
          columnSpacing: 15,

          columns: const [
            DataColumn(
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(''),
                ],
              ),
            ),
            DataColumn(
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NAME',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PREV LAP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            DataColumn(
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BEST LAP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(''),
                ],
              ),
            ),
          ],
          rows: racers.expand((racer) {
            List<DataRow> rows = [];
            bool isExpanded = racer.isExpanded ?? false;

            rows.add(DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Text(
                        '${racer.racePosition.position}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      racer.isExpanded = !isExpanded;
                    });
                  },
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${racer.registrationNumber} ${racer.firstName} ${racer.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${racer.racePosition.laps} | ${racer.extra.previousLapTime}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    '${racer.pqPosition.bestLapTime}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: racer.pqPosition.bestLapTime == bestLapTime &&
                              bestLapTime.toDouble() > 0.0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color.fromARGB(255, 13, 70, 15),
                    ),
                  ),
                ),
              ],
            ));

            if (isExpanded) {
              int lapNum = 1;
              rows.addAll(racer.passes.where((pass) => pass.lapTime != Time(seconds: 0)).map((pass) {
                return DataRow(cells: [
                  DataCell(SizedBox.shrink()),
                  DataCell(
                    Text(
                      'Lap ${lapNum++}: ${pass.lapTime}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  DataCell(SizedBox.shrink()),
                ]);
              }));
            }
            return rows;
          }).toList(),
        ),
      ),
    );
  }
}
