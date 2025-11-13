import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qubeyai/subscription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/balance_card.dart';
import 'package:qubeyai/screens/main_home_screen.dart';
import 'package:qubeyai/user_data_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // User input controllers
  final TextEditingController _savingNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _professionalQuestionController = TextEditingController();
  DateTime? _targetDate;
  String _selectedCurrency = "USD";

  // Checkbox options
  Map<String, bool> _savingGoals = {
    "Emergency Fund": false,
    "Gift": false,
    "New Car": false,
    "New House": false,
    "New Phone": false,
    "Vacation": false,
    "Other": false,
  };

  // Extra questions
  String? _preferredSavingFrequency; // e.g., Weekly, Monthly
  bool _investAlongsideSaving = false;

  // Press count for last page
  int _pressCount = 0;
  final int _requiredPresses = 3;

  // Currency list
  final List<String> _currencies = [
    "AUD - \$", "BRL - R\$", "CAD - \$", "CHF - CHF", "CNY - ¥", "DKK - kr",
    "EUR - €", "GBP - £", "HKD - \$", "INR - ₹", "JPY - ¥", "KRW - ₩", "MXN - \$",
    "MYR - RM", "NOK - kr", "NZD - \$", "PHP - ₱", "PKR - ₨", "RUB - ₽", "SAR - ﷼",
    "SEK - kr", "SGD - \$", "THB - ฿", "TRY - ₺", "TWD - \$", "USD - \$", "VND - ₫",
    "ZAR - R", "AED - د.إ", "ARS - \$", "CLP - \$", "COP - \$", "EGP - E£",
    "HUF - Ft", "IDR - Rp", "ILS - ₪", "NGN - ₦", "PLN - zł", "RON - lei", "UAH - ₴"
  ];

  // ✅ Updated Next Step Logic
  void _nextStep() {
    bool canProceed = true;

    // Mandatory checks
    if (_currentStep == 0 && !_savingGoals.values.any((selected) => selected)) {
      canProceed = false;
      _showError("Please select at least one financial goal.");
    }
    if (_currentStep == 1 && _savingNameController.text.trim().isEmpty) {
      canProceed = false;
      _showError("Please provide a name for your savings account.");
    }
    if (_currentStep == 2) {
      final amount = int.tryParse(_amountController.text.trim());
      if (amount == null || amount < 1) {
        canProceed = false;
        _showError("Please enter a valid numeric amount greater than 0.");
      }
    }
    if (_currentStep == 3 && _targetDate == null) {
      canProceed = false;
      _showError("Please select a target completion date.");
    }

    // ✅ Compulsory Saving Frequency (Page 5)
    if (_currentStep == 4 && _preferredSavingFrequency == null) {
      canProceed = false;
      _showError("Please select your preferred saving frequency before continuing.");
    }

    if (!canProceed) return;

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      setState(() {
        _pressCount++;
      });
      if (_pressCount <= _requiredPresses) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
    ));
  }

  Future<void> _goNext() async {
    final prefs = await SharedPreferences.getInstance();
    final isSubscribed = prefs.getBool('isSubscribed') ?? false;

    if (isSubscribed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
      );
    }
  }



  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Widget _buildDotProgressBar(int totalSteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index == _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          width: isActive ? 20 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[400],
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildDotProgressBar(6),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Page 1: Financial Goals
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Select Your Financial Goals",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 12),
                          const Text(
                            "Choose all objectives you are currently saving for. Multiple selections allowed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: _savingGoals.keys.map((goal) {
                              return Card(
                                color: Colors.grey[850],
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: CheckboxListTile(
                                  title: Text(goal,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  value: _savingGoals[goal],
                                  onChanged: (val) {
                                    setState(() {
                                      _savingGoals[goal] = val!;
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Colors.green,
                                  checkColor: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page 2: Savings Name
                  SingleChildScrollView(
                    child: _buildStep(
                      title: "Name Your Savings Account",
                      subtitle: "Provide a specific name for this savings goal.",
                      input: TextField(
                        controller: _savingNameController,
                        decoration: InputDecoration(
                          fillColor: Colors.grey[850],
                          filled: true,
                          border: const OutlineInputBorder(),
                          hintText: "E.g., 'Vacation Fund'",
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // Page 3: Target Amount + Currency
                  SingleChildScrollView(
                    child: _buildStep(
                      title: "Specify Your Target Amount",
                      subtitle: "Enter the exact amount you intend to save.",
                      input: Column(
                        children: [
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[850],
                              filled: true,
                              border: const OutlineInputBorder(),
                              hintText: "Enter numeric amount only",
                              hintStyle: const TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedCurrency,
                            items: _currencies
                                .map((currency) => DropdownMenuItem(
                              value: currency.split(" - ")[0],
                              child: Text(currency,
                                  style: const TextStyle(color: Colors.white)),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCurrency = val!;
                              });
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[850],
                              filled: true,
                              labelText: "Select Currency",
                              labelStyle: const TextStyle(color: Colors.white),
                              border: const OutlineInputBorder(),
                            ),
                            dropdownColor: Colors.grey[850],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page 4: Target Date
                  SingleChildScrollView(
                    child: _buildStep(
                      title: "Set a Target Completion Date",
                      subtitle: "Select a date by which you aim to achieve your goal.",
                      input: ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          _targetDate == null
                              ? "Pick Target Date"
                              : "${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  // Page 5: Saving Frequency
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Preferred Saving Frequency",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Choose how often you intend to add to this goal.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: ["Daily", "Weekly", "Monthly", "Quarterly"]
                                .map((freq) {
                              return Card(
                                color: Colors.grey[850],
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: RadioListTile<String>(
                                  title: Text(freq,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  value: freq,
                                  groupValue: _preferredSavingFrequency,
                                  onChanged: (val) {
                                    setState(() {
                                      _preferredSavingFrequency = val!;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page 6: Professional Question
                  SingleChildScrollView(
                    child: _buildStep(
                      title: "Your Long-Term Financial Vision",
                      subtitle:
                      "Please answer this question thoughtfully. It guides your financial planning.",
                      input: TextField(
                        controller: _professionalQuestionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          fillColor: Colors.grey[850],
                          filled: true,
                          border: const OutlineInputBorder(),
                          hintText:
                          "What is your ultimate financial vision for the next 10 years?",
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Previous"),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentStep < 6) {
                          _nextStep();
                        } else {
                          final userData = Provider.of<UserDataProvider>(context,
                              listen: false);
                          userData.setSavingDetails(
                            savingName: _savingNameController.text.trim(),
                            amount:
                            int.tryParse(_amountController.text.trim()) ?? 0,
                            currency: _selectedCurrency,
                            targetDate: _targetDate,
                            savingFrequency: _preferredSavingFrequency,
                            streakDays: userData.streakDays,
                          );


                          final prefs = await SharedPreferences.getInstance();
                          final days = _targetDate != null ? _targetDate!.difference(DateTime.now()).inDays : 30;
                          await prefs.setInt('goal_days', days);

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SubscriptionScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _currentStep == 6 ? Colors.green : Colors.blue,
                      ),
                      child: Text(
                        _currentStep == 5 ? "Continue" : "Next",
                        style:
                        const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
      {required String title, String? subtitle, required Widget input}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: Colors.white70, height: 1.4)),
          ],
          const SizedBox(height: 20),
          input,
        ],
      ),
    );
  }
}

class _streakDaysController {
  static var text;
}
