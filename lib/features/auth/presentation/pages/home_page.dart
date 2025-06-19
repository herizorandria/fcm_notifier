import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/contact_model.dart';
import 'package:wizi_learn/features/auth/data/models/formation_model.dart';
import 'package:wizi_learn/features/auth/data/repositories/contact_repository.dart';
import 'package:wizi_learn/features/auth/data/repositories/formation_repository.dart';
import 'package:wizi_learn/features/auth/presentation/pages/contact_page.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/contact_card.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/random_formations_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ContactRepository _contactRepository;
  late final FormationRepository _formationRepository;
  List<Contact> _contacts = [];
  List<Formation> _randomFormations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    _contactRepository = ContactRepository(apiClient: apiClient);
    _formationRepository = FormationRepository(apiClient: apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final contacts = await _contactRepository.getContacts();
      final formations = await _formationRepository.getRandomFormations(3);

      setState(() {
        _contacts = contacts;
        _randomFormations = formations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF6F4F3),
        title: const Text('Bienvenue sur Wizi Learn',
          style: TextStyle(
              color: Colors.brown,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // Section Formations
            if (_randomFormations.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RandomFormationsWidget(
                    formations: _randomFormations,
                    onRefresh: _refreshData,
                  ),
                ),
              ),

            // Section Contacts
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes contacts',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFFB07661),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactPage(contacts: _contacts),
                          ),
                        );
                      },
                      child: const Text('Voir tous'),
                    ),
                  ],
                ),
              ),
            ),
            if (_contacts.isEmpty)
              SliverFillRemaining(
                child: const Center(child: Text('Aucun contact disponible')),
              )
            else
              (() {
                final wantedRoles = ['commercial', 'formateur', 'pole_relation_client'];
                final filteredContacts = <String, Contact>{};
                for (final c in _contacts) {
                  if (wantedRoles.contains(c.role) && !filteredContacts.containsKey(c.role)) {
                    filteredContacts[c.role] = c;
                  }
                }
                final contactsToShow = filteredContacts.values.toList();
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ContactCard(contact: contactsToShow[index]),
                    childCount: contactsToShow.length,
                  ),
                );
              })(),
          ],
        ),
      ),
    );
  }
}