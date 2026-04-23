import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Frosted/card container used throughout the DailyCheckModal.
/// All sections (Watering, Observations, Feedback, Photos) use this wrapper.
Widget frostedCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: child,
  );
}

/// The watering section: Yes/No choice chips + amount + unit dropdown.
class WateringSection extends StatelessWidget {
  final bool? watered;
  final TextEditingController waterAmountController;
  final String selectedWaterUnit;
  final ValueChanged<bool> onWateredChanged;
  final ValueChanged<String> onUnitChanged;

  const WateringSection({
    super.key,
    required this.watered,
    required this.waterAmountController,
    required this.selectedWaterUnit,
    required this.onWateredChanged,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Watering',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Did you water the plant today?',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Yes'),
                selected: watered == true,
                onSelected: (_) => onWateredChanged(true),
                selectedColor: AppColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: watered == true
                      ? AppColors.primary
                      : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ChoiceChip(
                label: const Text('No'),
                selected: watered == false,
                onSelected: (_) => onWateredChanged(false),
                selectedColor: AppColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: watered == false
                      ? AppColors.primary
                      : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (watered == true) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: waterAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedWaterUnit,
                        isExpanded: true,
                        onChanged: (value) {
                          if (value != null) onUnitChanged(value);
                        },
                        items: <String>['ml', 'liters']
                            .map<DropdownMenuItem<String>>(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The observations section: pest toggle + notes text field.
class ObservationSection extends StatelessWidget {
  final bool pestsObserved;
  final TextEditingController pestNotesController;
  final ValueChanged<bool> onPestsChanged;

  const ObservationSection({
    super.key,
    required this.pestsObserved,
    required this.pestNotesController,
    required this.onPestsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Observations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Any pests or problems?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
              Switch(
                value: pestsObserved,
                activeColor: AppColors.primary,
                onChanged: onPestsChanged,
              ),
            ],
          ),
          if (pestsObserved) ...[
            const SizedBox(height: 10),
            TextField(
              controller: pestNotesController,
              decoration: InputDecoration(
                hintText: 'Describe issues noticed...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}

/// Nutrient input section for farmer-entered applied quantities.
class NutrientApplicationSection extends StatelessWidget {
  final TextEditingController nitrogenController;
  final TextEditingController phosphorusController;
  final TextEditingController potassiumController;

  const NutrientApplicationSection({
    super.key,
    required this.nitrogenController,
    required this.phosphorusController,
    required this.potassiumController,
  });

  @override
  Widget build(BuildContext context) {
    return frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrient Application',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter nutrients applied today (grams). Leave empty if not applied.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 12),
          _NutrientInputRow(
            label: 'Nitrogen (N)',
            controller: nitrogenController,
          ),
          const SizedBox(height: 10),
          _NutrientInputRow(
            label: 'Phosphorus (P2O5)',
            controller: phosphorusController,
          ),
          const SizedBox(height: 10),
          _NutrientInputRow(
            label: 'Potassium (K2O)',
            controller: potassiumController,
          ),
        ],
      ),
    );
  }
}

class _NutrientInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _NutrientInputRow({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0.0',
              suffixText: 'g',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
