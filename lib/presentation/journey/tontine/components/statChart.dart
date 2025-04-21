import 'package:faris/data/models/stat_tontine_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatChart extends StatelessWidget {
  final List<StatTontine> statTontines;

  const StatChart({Key? key, required this.statTontines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta){
                //print("VALUE => $value");
                return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        "${statTontines[value.toInt()].name}",
                    style: TextStyle(color: Color(0xff7589a2),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,),
                    )
                );
              },
              reservedSize: 38
            )
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta){
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Color(0xff7589a2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                  textAlign: TextAlign.left,
                );
              }
            )
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(statTontines.length, (index){
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: statTontines[index].value!.toDouble(),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: false,
                    toY: statTontines.map((stat) => stat.value!.toDouble()).reduce((a,b) => a > b ? a : b),
                    color: const Color(0xffDCF0E9),
                  )
              )
            ]
          );
        }),
        gridData: const FlGridData(show: false)
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }
}
