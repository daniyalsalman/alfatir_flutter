// lib/zakat_calculator_screen.dart

import 'package:flutter/material.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => ZakatCalculatorScreenState();
}

class ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _goldSilverController = TextEditingController();
  final TextEditingController _investmentsController = TextEditingController();
  final TextEditingController _liabilitiesController = TextEditingController();

  double _totalNetAssets = 0.0;
  double _zakatPayable = 0.0;
  bool _calculated = false;

  void _calculateZakat() {
    if (_formKey.currentState!.validate()) {
      // Parse inputs, defaulting to 0.0 if empty
      final double cash = double.tryParse(_cashController.text) ?? 0.0;
      final double goldSilver = double.tryParse(_goldSilverController.text) ?? 0.0;
      final double investments = double.tryParse(_investmentsController.text) ?? 0.0;
      final double liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;

      // Net Assets = Total Assets - Liabilities
      final double netAssets = (cash + goldSilver + investments) - liabilities;

      setState(() {
        _totalNetAssets = netAssets;
        // Zakat is 2.5% of net assets
        _zakatPayable = (netAssets > 0) ? netAssets * 0.025 : 0.0;
        _calculated = true;
      });

      // Hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  void _reset() {
    _cashController.clear();
    _goldSilverController.clear();
    _investmentsController.clear();
    _liabilitiesController.clear();
    setState(() {
      _totalNetAssets = 0.0;
      _zakatPayable = 0.0;
      _calculated = false;
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _goldSilverController.dispose();
    _investmentsController.dispose();
    _liabilitiesController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your assets details to calculate Zakat (2.5%)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(_cashController, 'Cash in Hand & Bank', Icons.attach_money),
              _buildTextField(_goldSilverController, 'Value of Gold & Silver', Icons.money),
              _buildTextField(_investmentsController, 'Investments & Business Assets', Icons.show_chart),
              _buildTextField(_liabilitiesController, 'Debts & Liabilities', Icons.money_off),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateZakat,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Calculate'),
              ),

              if (_calculated) ...[
                const SizedBox(height: 30),
                Card(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).primaryColor)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text('Total Net Assets', style: TextStyle(fontSize: 16)),
                        Text(
                          _totalNetAssets.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 30),
                        const Text('Zakat Payable (2.5%)', style: TextStyle(fontSize: 18, color: Colors.green)),
                        const SizedBox(height: 5),
                        Text(
                          _zakatPayable.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.green
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    '* Ensure your net assets exceed the Nisab threshold before paying.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}