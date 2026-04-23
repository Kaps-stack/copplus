import 'package:copplus/providers/find_service_provider.dart';
import 'package:copplus/routes/app_routes.dart';
import 'package:copplus/utils/app_constants.dart';
import 'package:copplus/utils/location_data.dart';
import 'package:copplus/widgets/custom_bottom_nav.dart';
import 'package:copplus/widgets/custom_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FindServicePage extends StatelessWidget {
  const FindServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final findProv = context.watch<FindServiceProvider>();
    const primaryGold = Color(0xFFBC7400);

    final List<String> communes =
        (LocationData.data['RD Congo']['Kinshasa'] as Map<String, dynamic>).keys
            .toList()
          ..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: Stack(
        children: [
          // 1. LE CONTENU (FORMULAIRE)
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Padding pour ne pas être caché par la TopBar fixée
              const SliverToBoxAdapter(child: SizedBox(height: 110)),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  140,
                ), // Padding bas pour la BottomNav
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionTitle("Service souhaité"),
                    const SizedBox(height: 12),
                    _buildServiceGrid(findProv, primaryGold),

                    if (findProv.isOtherServiceSelected) ...[
                      const SizedBox(height: 12),
                      _buildModernTextField(
                        "Précisez le service souhaité...",
                        Icons.edit_note,
                        controller: findProv.otherServiceController,
                      ),
                    ],

                    const SizedBox(height: 30),
                    _sectionTitle("Vos exigences"),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildModernDropdown(
                            AppConstants.sexes,
                            findProv.selectedSexe,
                            "Sexe",
                            (v) => findProv.updateSexe(v ?? ""),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernDropdown(
                            ["18-25", "26-35", "36-45", "45+"],
                            findProv.selectedAge,
                            "Âge",
                            (v) => findProv.updateAge(v ?? ""),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModernDropdown(
                      communes,
                      findProv.selectedCommune,
                      "Commune",
                      (v) => findProv.updateCommune(v ?? ""),
                    ),
                    const SizedBox(height: 12),
                    _buildModernDropdown(
                      AppConstants.niveauxEtude,
                      findProv.selectedLevel,
                      "Niveau d'études",
                      (v) => findProv.updateLevel(v ?? ""),
                    ),
                    const SizedBox(height: 12),
                    _buildModernTextField(
                      "Langues parlées",
                      Icons.translate,
                      onCh: (v) => findProv.languages = v,
                    ),

                    const SizedBox(height: 30),
                    _sectionTitle("Budget & Horaire"),
                    const SizedBox(height: 15),
                    _buildPriceInput(findProv, primaryGold),
                    const SizedBox(height: 12),
                    _buildDaySelector(findProv, primaryGold),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeTile(
                            context,
                            "Début",
                            findProv.startTime,
                            (t) => findProv.updateTime(t),
                            primaryGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeTile(
                            context,
                            "Fin",
                            findProv.endTime,
                            (t) => findProv.updateEndTime(t),
                            primaryGold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    _sectionTitle("Détails du poste"),
                    const SizedBox(height: 15),
                    _buildModernTextField(
                      "Autres exigences...",
                      Icons.add_moderator,
                      onCh: (v) => findProv.extraRequirements = v,
                    ),

                    const SizedBox(height: 25),
                    _sectionSubtitle("Avantages à offrir"),
                    _buildDynamicList(
                      items: findProv.benefitsList,
                      hint: "Ex: Logement, Repas...",
                      onAdd: (val) =>
                          findProv.addItem(findProv.benefitsList, val),
                      onRemove: (idx) =>
                          findProv.removeItem(findProv.benefitsList, idx),
                      color: primaryGold,
                    ),

                    const SizedBox(height: 25),
                    _sectionSubtitle("Tâches journalières"),
                    _buildDynamicList(
                      items: findProv.tasksList,
                      hint: "Ex: Nettoyage, Cuisine...",
                      onAdd: (val) => findProv.addItem(findProv.tasksList, val),
                      onRemove: (idx) =>
                          findProv.removeItem(findProv.tasksList, idx),
                      color: primaryGold,
                    ),

                    const SizedBox(height: 40),
                    _buildSubmitButton(findProv, context, primaryGold),
                  ]),
                ),
              ),
            ],
          ),

          // 2. TOP BAR FIXÉE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () =>
                  Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),

          // 3. BOTTOM NAV FIXÉE
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.findService),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE DESIGN ---

  Widget _sectionTitle(String t) => Text(
    t.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w900,
      color: Colors.grey,
      letterSpacing: 1.5,
    ),
  );

  Widget _sectionSubtitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildServiceGrid(FindServiceProvider prov, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.servicesBase.map((s) {
        final isSel = prov.selectedService == s;
        return InkWell(
          onTap: () => prov.updateService(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSel ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSel ? color : Colors.grey[200]!),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              s,
              style: TextStyle(
                color: isSel ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernDropdown(
    List<String> items,
    String? val,
    String hint,
    Function(String?) onCh,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onCh,
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    String hint,
    IconData icon, {
    TextEditingController? controller,
    Function(String)? onCh,
  }) {
    return TextField(
      controller: controller,
      onChanged: onCh,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildPriceInput(FindServiceProvider prov, Color color) {
    return Column(
      children: [
        TextField(
          controller: prov.salaryController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            String formatted = prov.formatMoney(v);
            prov.salaryController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
          decoration: InputDecoration(
            hintText: "Salaire mensuel souhaité (CDF)",
            prefixIcon: Icon(Icons.payments_outlined, color: color),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
        RangeSlider(
          values: prov.salaryRange,
          min: 0,
          max: 2000000,
          activeColor: color,
          inactiveColor: color.withOpacity(0.1),
          onChanged: (v) {
            prov.updateSalary(v);
            prov.salaryController.text = prov.formatMoney(
              v.end.toInt().toString(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDaySelector(FindServiceProvider prov, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: prov.allDays.map((day) {
          final isSel = prov.selectedDays.contains(day);
          return InkWell(
            onTap: () => prov.toggleDay(day),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isSel ? color : Colors.grey[100],
              child: Text(
                day[0],
                style: TextStyle(
                  color: isSel ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    String label,
    TimeOfDay? time,
    Function(TimeOfDay) onCh,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (t != null) onCh(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              time == null ? label : time.format(context),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicList({
    required List<String> items,
    required String hint,
    required Function(String) onAdd,
    required Function(int) onRemove,
    required Color color,
  }) {
    final TextEditingController listCtrl = TextEditingController();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: listCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    onAdd(val);
                    listCtrl.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: color, size: 38),
              onPressed: () {
                if (listCtrl.text.isNotEmpty) {
                  onAdd(listCtrl.text);
                  listCtrl.clear();
                }
              },
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemove(index),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(
    FindServiceProvider prov,
    BuildContext context,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: prov.isLoading ? null : () => prov.submitSearch(context),
        child: prov.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "SOUMETTRE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}
