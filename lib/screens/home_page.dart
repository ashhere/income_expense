import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personalfinanceapp/constants/colors.dart';
import 'package:personalfinanceapp/models/user_model.dart';
import 'package:personalfinanceapp/services/auth_serrvice.dart';
import 'package:personalfinanceapp/services/fin_service.dart';
import 'package:personalfinanceapp/widgets/apptext.dart';
import 'package:personalfinanceapp/widgets/dashboard_widget.dart';
import 'package:personalfinanceapp/widgets/mydivider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchInitialData(context);
    });
  }

  Future<void> _fetchInitialData(BuildContext context) async {
    final finService = Provider.of<UserServvice>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userModel = await authService.getCurrentUser();
    if (userModel != null) {
      finService.calculateTotalIncomeForUser(userModel.id);
      finService.calculateTotalExpenseForUser(userModel.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 47, 73),

        //  title:const Text('finance',style: TextStyle(fontSize:30,color: Colors.white,),),

        //  leading: const Padding(
        //    padding:  EdgeInsets.only(left: 20.0,top: 10),
        //    child: Icon(Icons.local_atm,color: Color.fromARGB(255, 228, 235, 239),size: 50,),

        //  ),
        title: Padding(
          padding: const EdgeInsets.only(left: 0, top: 05),
          child: Container(
            width: 50,
            height: 50,
            child: Image.asset('assets/img/wallet1.png'),
          ),
        ),
      ),
      body: Consumer<UserServvice>(
        builder: (context, finService, _) {
          return _buildBody(context, finService);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserServvice finService) {
    final totalExpense = finService.totalExpense;
    final totalIncome = finService.totalIncome;

    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthService>(
              builder: (context, authService, child) {
                return FutureBuilder<UserModel?>(
                  future: authService.getCurrentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.hasData) {
                        final userData = snapshot.data!;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      AppText(
                                        data: "Welcome!",
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      AppText(
                                        data: "${userData.name}",
                                        color: Colors.white,
                                        size: 26,
                                        fw: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'profile');
                                  },
                                  child: const CircleAvatar(
                           
                                    backgroundColor:  Color.fromARGB(255, 8, 64, 96),
                                        backgroundImage: AssetImage('assets/img/teen.png'),
                                    // child: Text(
                                    //   "${userData.name[0].toUpperCase()}",
                                    //   style: const TextStyle(
                                    //       color: Colors.white70, fontSize: 25),
                                    // ),
                                  ),
                                )
                              ],
                            ),
                            MyDivider(),
                            SizedBox(
                              height: 20,
                            ),
                            DashboardItemWidget(
                              onTap1: () {
                                Navigator.pushNamed(context, "listexpense",
                                    arguments: totalExpense);
                              },
                              onTap2: () {
                                Navigator.pushNamed(context, "listincome",
                                    arguments: totalIncome);
                              },
                              titleOne: "Expense\n $totalExpense",
                              titleTwo: "Income \n $totalIncome",
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            DashboardItemWidget(
                              onTap1: () {
                                Navigator.pushNamed(context, 'addExpense',
                                    arguments: userData.id);
                              },
                              onTap2: () {
                                Navigator.pushNamed(context, 'addIncome',
                                    arguments: userData.id);
                              },
                              titleOne: "Add Expense",
                              titleTwo: "Add Income",
                            ),
                            SizedBox(height: 30,),
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppText(
                                    data: "Income vs Expense",
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  AspectRatio(
                                    aspectRatio: 1.3,
                                    child: PieChart(PieChartData(
                                      sectionsSpace: 5,
                                      centerSpaceColor: Colors.transparent,
                                      sections: [
                                        PieChartSectionData(
                                          radius: 50,
                                          color: chartColor1,
                                          value: finService.totalExpense,
                                          title: "Expense",
                                          titleStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          titleStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          color: chartColor2,
                                          value: finService.totalIncome,
                                          title: "Income",
                                          radius: 50,
                                        ),
                                      ],
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
