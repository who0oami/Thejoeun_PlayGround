import 'package:chart_project/model/developer_data.dart';
import 'package:chart_project/view/line.dart';
import 'package:chart_project/view/multi.dart';
import 'package:chart_project/view/scatter.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin {
  //Property
  late TooltipBehavior tooltipBehavior;
  late TabController controller;
  late List<DeveloperData> data;
  late List<DeveloperData> data2;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
    data = [];
    data2 = [];
    tooltipBehavior = TooltipBehavior(enable: true);
    addData();
    addData2();
  }

  addData() {
    data.add(DeveloperData(year: 2017, developers: 19000));
    data.add(DeveloperData(year: 2018, developers: 40000));
    data.add(DeveloperData(year: 2019, developers: 35000));
    data.add(DeveloperData(year: 2020, developers: 37000));
    data.add(DeveloperData(year: 2021, developers: 45000));
  }

  addData2() {
    data2.add(DeveloperData(year: 2017, developers: 9000));
    data2.add(DeveloperData(year: 2018, developers: 20000));
    data2.add(DeveloperData(year: 2019, developers: 17000));
    data2.add(DeveloperData(year: 2020, developers: 18000));
    data2.add(DeveloperData(year: 2021, developers: 33000));
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chart'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: TabBarView(
        controller: controller,
        children: [
          Line(data: data),
          Scatter(data: data),
          Multi(data: data, data2: data2),
          Scatter(data: data),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        height: 80,
        child: TabBar(
          controller: controller,
          labelColor: Colors.white,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          indicatorColor: Colors.blueGrey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 5,
          tabs: [
            Tab(icon: Icon(Icons.looks_one), text: 'Bar'),
            Tab(icon: Icon(Icons.looks_two), text: 'Line'),
            Tab(icon: Icon(Icons.looks_3), text: 'multi'),
            Tab(icon: Icon(Icons.looks_4), text: 'Scatter'),
          ],
        ),
      ),
    );
  }
}
